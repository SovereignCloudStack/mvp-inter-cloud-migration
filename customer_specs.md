# Customer specifications

POV: Customer

## Current IS-situatiuon

- SCS cloud stacks are production ready
  - Workload is running
  - Migration is currently not possible or only manual
- SCS standards are implemented
- Reasons why customers migrate
  - 1. Know where the data is
  - 2. Solution that is secure and auditable
  - 3. Price is too high
  - 4. Increase performance (e.g. I/O)

## Desired SHOULD-situation

- What is the ultimate goal?
  - Customer would like to migrate from AWS to something reasonably priced
  - Choose one minimal scenario:
    - Split this into multiple small components
    - Pre-requirements should be defined for an MVP
    - VM level
- What (technical) functionality should be available?
  - We should have some sort of microservice agent inside the clouds to handle migration tasks
  - One for TBD function
- What interfaces should avaiable?
  - We need tooling for skilled workers but not for CSPs
  - Triger a migration:
    - Self-Service: Allow an API usage to provide an ID and the credentials for the target
    - CSP does this for you with a Ticket
  - Check if the migration succeeded
- Who is responsible for what?
  - Customer is responsible for the workload migration itself
  - SCS needs to provide the Agent Image -> applicance, can even be a new standard
  - developing and maintaining the code is in SCS responsibility
- How should thinks be maintained and updated?
  - Release cycles of SCS

## Thoughs

1. Scenarios:

   - Public to public
   - Private to public
   - Public to private

2. Project Management Setup

   - has to be duplicated upfront to manage VMs later on
   - Migrate tenants and then workload
   - Resource management, user and access rights management, etc.

Why do customers consider migrating? Worth reading:
<https://www.techspot.com/news/97300-leaving-cloud-basecamp-spent-32-million-year-rent.html>

Additional article:
<https://changelog.com/shipit/77>

## Long term goals

1. SCS -> SCS
2. AWS -> SCS
3. VMware -> SCS
