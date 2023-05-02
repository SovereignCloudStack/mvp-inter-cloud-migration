# MVP: Inter cloud migration

One of the mail goals of SCS is to enable consumers of SCS based clouds, to flawlessly shift workloads from one SCS cloud to another.

This repository will be the MVP to bring this functionality to SCS.
As this is a MVP, we only focus on a small minimum, but would expand in the future of course!

## Scenario

- A customer should be enabled to migrate his VM workload from one SCS based cloud to another easily
- Some sort of microservice agent inside each cloud should be able to handle these tasks
- The CSP _can_ also do this for the customer, but the tools should be made available for the customer in the first hand

## Technical details

- SCS should provide appliance Agent Images, so customers can easily consume them for desired migration tasks
- This image is owned, developed and maintained by the SCS community
- This image is updated each release cycle of SCS
- We ignore project management setups and config management systems for the moment
  - e.g. user and right management inside the clouds
  - e.g. chef server or periodic ansible jobs
  - VPN, private clouds, etc. are out of scope
- after evaluation of possible existing tools (see [thoughs.md](thoughts.md)) we'll probably need to develop something on our own
  - Python (FastAPI, Typer, openstacksdk, Postman), restic, rsync, streaming binary?
  - Database to store states
  - Hooks for pre-migration and post-migration scripts (e.g. shutdown database, etc.)
  - success status messages (that can be asynchronously queried)
  - credentials are currenly out of scope
