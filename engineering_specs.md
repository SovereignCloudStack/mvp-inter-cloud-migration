# Engineering specifications

POV: Developer

- How are things done?
  - !!! Evaluate other tools:
    - <https://github.com/os-migrate/os-migrate>
  - Direct Cloud to Cloud migration, no proxy via developer laptop
  - Microservice agent(s):
    - Prepare for migration
    - Signaling agent (start migration, stop old, migration is done)
    - Spawn VM in a cloud
    - Migration status checker (was the migration successful?)
    - Cleanup old VM
    - Backup agent (functionally TBD)
    - Dummy transfer speed checker (not part of MVP)
  - Tools for skilled workers
    - Client program to connect to microservices
    - Client supports hooks (e.g. bash scripts)
    - Client != client running inside a guest VM
    - Client should be stateless
  - Self-Service
  - APIs
  - Crendential handeling
  - Hooks!!!
    - E.g. shut down a database before migration
    - Should be in the client tools
    - Also readiness hooks, etc.
  - Some sort of event storage
- Which technologies will be used to reach the SHOULD state?
  - Python
    - FastAPI
    - Typer
    - OpenStackSDK
    - Postman
  - Transfer protocol for large data amounts:
    - 1. restic
    - 2. rsync -e ssh -z?
    - 3. streaming binary?
    - > Needs research
  - Database
- Exact definitions of the SHOULD goals (positive delimitations)
  - We can migrate EASILY one VM from cloud a to cloud b with as few interaction of a human as possible
  - VMs and applications inside the VMs are stopped, packed, shipped, started automatically (also app)
    - application hooks might be optional for this MVP
  - Success message (should be query-able)
    - maybe not in the MVP
  - Include attached block devices
- Exact definitions of the NOT SHOULD goals (negative delimitations)
  - Time estimate for migrations
  - VPN, private clouds, etc. are out of scope!

- How do we define acceptance?
- At what point(s) do we consider things as DONE?
- How will the quality be ensured?
- What rework is expected?
  - Time estimate for migrations
