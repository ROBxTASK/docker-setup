print('Start #################################################################');

db = db.getSiblingDB('devreg_prod_db');
db.createUser(
  {
    user: 'devreg',
    pwd: '0IYsZdgOB88bSV19dS40',
    roles: [{ role: 'readWrite', db: 'devreg_prod_db' }],
  },
);
db.createCollection('users');

db = db.getSiblingDB('devreg_dev_db');
db.createUser(
  {
    user: 'devreg',
    pwd: '0IYsZdgOB88bSV19dS40',
    roles: [{ role: 'readWrite', db: 'devreg_dev_db' }],
  },
);
db.createCollection('users');

db = db.getSiblingDB('devreg_staging_db');
db.createUser(
  {
    user: 'devreg',
    pwd: '0IYsZdgOB88bSV19dS40',
    roles: [{ role: 'readWrite', db: 'devreg_staging_db' }],
  },
);
db.createCollection('users');

print('END #################################################################');
