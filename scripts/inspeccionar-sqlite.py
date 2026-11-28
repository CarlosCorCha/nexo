"""Inspección de solo lectura para la reproducción del manual; Python 3 estándar."""
from pathlib import Path
import argparse, json, sqlite3, sys

sys.stdout.reconfigure(encoding='utf-8')

p = argparse.ArgumentParser()
p.add_argument('database', type=Path)
p.add_argument('--output', type=Path)
a = p.parse_args()
path = a.database.resolve(strict=True)
with sqlite3.connect(path.as_uri()+'?mode=ro', uri=True) as db:
    db.row_factory = sqlite3.Row
    query = lambda sql: [dict(r) for r in db.execute(sql)]
    result = {
        'database':str(path),
        'integrity':db.execute('PRAGMA quick_check').fetchone()[0],
        'tables':query("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"),
        'migrations':query('SELECT MigrationId, ProductVersion FROM __EFMigrationsHistory ORDER BY MigrationId'),
        'users':query('SELECT Id, UserName, DisplayName, Email, LastAccessUtc FROM AspNetUsers ORDER BY UserName'),
        'roles':query('SELECT Id, Name FROM AspNetRoles ORDER BY Name'),
        'relations':query('SELECT UserId, RoleId FROM AspNetUserRoles ORDER BY UserId, RoleId')
    }
if a.output:
    a.output.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print('Base inspeccionada en modo de solo lectura')
print('Integridad:',result['integrity'])
print('Tablas:',len(result['tables']))
print('Migración:',', '.join(r['MigrationId'] for r in result['migrations']))
print('Usuarios:',len(result['users']),'-',', '.join(r['UserName'] for r in result['users']))
print('Perfiles:',len(result['roles']),'-',', '.join(r['Name'] for r in result['roles']))
print('Relaciones usuario perfil:',len(result['relations']))
