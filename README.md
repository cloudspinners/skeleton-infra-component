
This repository is a messy work in progress, not intended to be used for real.

I'm using this repository to work out a standard project structure for infrastructure projects. It uses a Rakefile to manage infrastructure instances. I have drawn on [InfraBlocks](https://github.com/infrablocks) for Terraform modules, and I used the [InfraBlocks ConcourseCI](https://github.com/infrablocks/end-to-end-concourse-ci) project as a starting point for this one.

# Goals of this effort:

- Create a standard project structure that can be used for different infrastructure projects. Avoid having to reinvent this wheel for every new project.
- Create a build tool (starting with the Rakefile, although it might evolve into a standalone commandline tool) to manage infrastructure instances from the standard project structure. Rather than needing to customize the build file for each project, I would like it to dynamically work out the right things to do based on the project structure and configuration files.
- Establish a set of conventions, so that infrastructure projects can be built, and can integrate with one another, based on [convention over configuration](https://en.wikipedia.org/wiki/Convention_over_configuration).
- The project structure should make it easy to manage infrastructure and environments using [infrastructure pipelines](http://infrastructure-as-code.com/book/2017/08/02/environment-pipeline.html)

I plan on using this repository, and related ones, as examples of infrastructure project patterns. It will ideally be something people can use to structure new projects, and get up and running quickly. I do not intend this project as a library, framework, or module that you can fork and use to pull updates into your project. Copy it for your own project, fix it, tweak it, make it your own. I'd love to see conventions evolve from this and become useful to people, but I don't intend the code itself to become a supported thing.


## Opinionated software

I'm creating this project structure and conventions as [opinionated software](https://medium.com/@stueccles/the-rise-of-opinionated-software-ca1ba0140d5b). It assumes you want to use follow Infrastructure as Code, and in particular, that you want to apply agile engineering practices like TDD, CI, and CD to your infrastructure. It aims to make it easy to work this way. If you disagree with my opinions, that's fine, but the way I set this stuff up might not work as well for you.


## Tooling and platforms

This repository works with AWS at the moment. It should be extensible to Azure, GCE, and even other IaaS platforms supported by Terraform, in the future.

It uses Terraform, and pretty much assumes it. I'd like to think the project structure and conventions could be adapted to projects using cloud-specific tools (CloudFormation, etc.) or other environment provisioning tools. Particularly, conventions for integrating different infrastructure projects could work across tool stacks.


# Differences from the InfraBlocks examples

I started this by copying the [InfraBlocks ConcourseCI](https://github.com/infrablocks/end-to-end-concourse-ci) project, but have made some changes:

- Structure of the component's elements, particularly the "delivery" and "deployment" concept (which I should explain below).
- I put the configuration files for each element into the folder for that element. So rather than having the configuration files all live under the `./config` folder, there is a `stack.yaml` file in the folder for each element.
- I added `component-local.yaml`, which allows a user to override settings without checking them into the repository. This can be useful for developers on a project to have their own settings (especially the `deployment_identifier`). It's also useful for an example project like this one, you can set things to make it work for yourself, without having to change files from the actual project checkout.
- Started on making the Rakefile work out what to do dynamically. So it looks at the directory structure (especially things under the `./delivery` and `./deployment` folders), and adds targets to build infrastructure depending on what it finds there.
- Started on making the back end / state management something that happens automatically. Rather than having the option to configure what state buckets are named, what paths the state is stored in, etc., my Rakefile just decides what these will be. Convention over configuration, opinionated software, etc.
- Added a "delivery-statebucket", which is where the state for each deployment statebucket goes, as well as state for delivery things like the pipeline
- I'm not really using the term "role". I tend to use "stack" instead.
- I've merged some of the roles from the infrablocks concourse example into single stacks. So domain, network, and maybe services are all included in the "cluster" stack.


## Stuff that I've broken

- Cross-region. The way I've messed with the configurations might make it difficult to override regions for different bits.
- The actual docker images and things aren't working at the moment.
- The `./account` stuff is an idea, but I haven't done anything with it yet.
- The ruby/dotenv stuff. I may not have broken it, but I haven't been using it, so it may be a bit messed up.


# Structure

The repository represents a single "Component", which is a collection of different infrastructure projects - "[Stacks](http://infrastructure-as-code.com/patterns/2018/03/28/defining-stacks.html)" - that integrate together to provide some particular capability.

## Deployment and Delivery

You can create multiple instances of the component. Each instance is a "delivery", with its own "delivery_identifier". These are analogous to environments. (InfraBlocks, and I, have avoided using the term "environment" because it tends to be overloaded, used to mean different things in different organisations.)

This project has a folder `./deployment`. Each subfolder of this is a stack definition - a Terraform project - which is instantiated as part of a deployment. Sometimes I call these "deployment stacks".

There is also a folder called `./delivery`, which also has subfolders, each holding the definitions to provision a stack. However, these delivery stacks are normally only provisioned once. So there is (or will be soon) a delivery/pipeline stack, which creates pipelines to manage testing, provisioning, and updating deployments of the component.


## Statebucket stacks

Each deployment has its own statebucket. The definition for this is in `./deployment/statebucket`. The Rakefile treats this stack differently, based on its folder name, setting its terraform backend configuration to store its state in the delivery statebucket. Which lives in the `./delivery-statebucket` folder. This stack is unique, in that it doesn't store its state remotely. This state can be checked into the repository - it's essentially a bootstrapping thing, that has to be created first.

The reason for having a separate statebucket for each deployment is because the terraform state may include sensitive information. So the state for production deployments can be given different permissions than those used for development.


# Using this stuff

As I mentioned earlier, this repository is a messy work in progress, not intended to be used for real. To see what can be done, run `./go -T`, and you'll get a list of tasks in the Rakefile. A rough guide to using it:

- Create a file `./component-local.yaml`, using `./example-component-local.yaml` as a starting point.
- Run `./go delivery:statebucket:provision` to create your delivery statebucket. (You can run `plan` instead of provision for all steps, to see what Terraform will do, and `destroy` to tear down your infrastructure).
- Run `./go deployment:statebucket:provision` to make a statebucket for your sandbox deployment.
- Run `./go deployment:cluster:provision` to make an ECS cluster.

That's all you can do as of this commit. I may have added more stuff since, and not updated this readme.

To tear down your infrastructure, you'll need to run those commands in the reverse order. Otherwise, you may have dependencies which stop you from destroying. And if you destroy a statebucket before you destroy stacks whose state is stored in that statebucket, you won't be able to automatically destroy the stack. You'll have to point and click your way through all the things. Sorry.

