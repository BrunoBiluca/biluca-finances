import {
	App,
	normalizePath,
	Notice,
	Plugin,
	PluginSettingTab,
	Setting,
	TFile,
	TFolder,
} from "obsidian";

interface Settings {
	mySetting: string;
}

const DEFAULT_SETTINGS: Settings = {
	mySetting: "default",
};

export default class BilucaProjDocHelper extends Plugin {
	settings: Settings;

	async onload() {
		await this.loadSettings();

		this.addSettingTab(new BilucaProjDocHelperSettingTab(this.app, this));

		this.registerEvent(
			this.app.workspace.on("file-menu", (menu, file) => {
				menu.addItem((item) => {
					item
						.setTitle("Atualizar identificadores pelo DRP ID")
						.setIcon("document")
						.onClick(async () => {
							this.renameFilesInFolder(file.path);
						});
				});
			})
		);
	}

	onunload() {}

	async loadSettings() {
		this.settings = Object.assign({}, DEFAULT_SETTINGS, await this.loadData());
	}

	async saveSettings() {
		await this.saveData(this.settings);
	}

	async renameFilesInFolder(folderPath: string) {
		const folder = this.app.vault.getAbstractFileByPath(folderPath);

		if (!(folder instanceof TFolder)) {
			return;
		}

		const files = folder.children.filter(
			(child) => child instanceof TFile
		) as TFile[];

		const drpId = this.findDRPId(folder.name);
		if (!drpId) {
			new Notice("Nenhum DRP ID encontrado na pasta atual.");
			return;
		}

		const drpFile = files.find((f) => this.isDocType(f.basename, ["DRP"]));
		await this.renameDRP(drpFile!, drpId);

		const docs = files.filter((f) => this.isDocType(f.basename, ["RF", "RNF"]));
		const docsInfo = docs
			.map((f) => this.getDocInfo(f))
			.sort((i1, i2) => parseInt(i1.docId!) - parseInt(i2.docId!));

		let index = 1;
		let lastDocId = docsInfo[0].docId;
		for (const docInfo of docsInfo) {
			const file = docs.find((f) => f.basename === docInfo.oldName);

			if (lastDocId !== docInfo.docId) {
				index++;
				lastDocId = docInfo.docId;
			}

			await this.renameDoc(
				file!,
				drpId,
				index < 10 ? "0" + index : index.toString(),
				docInfo.subDocId
			);
		}
	}

	isDocType(docName: string, types: string[]): boolean {
		return types.some((t) => docName.startsWith(t));
	}

	findDRPId(text: string): string | null {
		const numbers: string[] | null = text.match(/\d+/g);
		return numbers ? numbers[0] : null;
	}

	findDocId(text: string): string[] | null {
		const numbers: string[] | null = text.match(/\d+/g);
		return numbers ? numbers.splice(1) : null;
	}

	getDocInfo(file: TFile) {
		const docId = this.findDocId(file.basename);
		return { oldName: file.basename, docId: docId?.[0], subDocId: docId?.[1] };
	}

	async renameDRP(file: TFile, drpId: string) {
		const currentName = file.basename;

		let newName = currentName;
		const title = currentName.split("-")[1].trim();
		newName = "DRP " + drpId + " - " + title;

		await this.updateDocument(file, newName);
	}

	async renameDoc(
		file: TFile,
		drpId: string,
		docId: string,
		subDocId?: string
	) {
		const currentName = file.basename;

		let newName = currentName;
		const title = currentName.split("-")[1].trim();
		const docType = currentName.split(" ")[0].trim();

		const newSubDocId = subDocId ? "." + subDocId : "";
		if (subDocId) {
			subDocId = "." + subDocId;
		}
		newName = docType + " " + drpId + "." + docId + newSubDocId + " - " + title;

		await this.updateDocument(file, newName);
	}

	private async updateDocument(file: TFile, newName: any) {
		if (file.basename === newName) {
			return;
		}
		try {
			const newPath = normalizePath(
				`${file.parent?.path}/${newName}.${file.extension}`
			);
			await this.app.fileManager.renameFile(file, newPath);
			await this.updateFileTitle(file, newName);
		} catch (error) {
			console.error(`Erro ao renomear ${file.path}:`, error);
		}
	}

	async updateFileTitle(file: TFile, newName: string) {
		try {
			const content = await this.app.vault.read(file);
			const lines = content.split("\n");
			lines[0] = `# ${newName}`;
			await this.app.vault.modify(file, lines.join("\n"));
		} catch (error) {
			console.error(`Erro ao atualizar título de ${file.path}:`, error);
		}
	}
}

class BilucaProjDocHelperSettingTab extends PluginSettingTab {
	plugin: BilucaProjDocHelper;

	constructor(app: App, plugin: BilucaProjDocHelper) {
		super(app, plugin);
		this.plugin = plugin;
	}

	display(): void {
		const { containerEl } = this;

		containerEl.empty();

		new Setting(containerEl)
			.setName("Setting #1")
			.setDesc("It's a secret")
			.addText((text) =>
				text
					.setPlaceholder("Enter your secret")
					.setValue(this.plugin.settings.mySetting)
					.onChange(async (value) => {
						this.plugin.settings.mySetting = value;
						await this.plugin.saveSettings();
					})
			);
	}
}
