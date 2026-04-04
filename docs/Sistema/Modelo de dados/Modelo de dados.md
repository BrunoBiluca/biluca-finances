# Modelo de dados

# accountability

Registros de contabilidade.

### Referências

```sql
-- identificador de contabilidade
FOREIGN KEY (identification_id) REFERENCES accountability_identifications(id) ON DELETE SET NULL
```

### Campos

```sql
id INTEGER PRIMARY KEY      -- identificador
description TEXT            -- descrição original
value REAL                  -- valor
createdAt TEXT              -- momento que foi criado
insertedAt TEXT             -- momento que foi inserido no sistema
updatedAt TEXT              -- momento que teve alguma alteração
identification_id TEXT      -- referência ao identificador
description_alt TEXT        -- descrição alternativa
```

# accountability_identifications

Identificadores que categorizam os registros de contabilidades

### Campos

```sql
id TEXT PRIMARY KEY
description TEXT
color INTEGER
insertedAt TEXT
updatedAt TEXT
icon TEXT
```
