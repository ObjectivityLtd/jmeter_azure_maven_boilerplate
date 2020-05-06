# jmeter_azure_maven_boilerplate

This is a boilerplate project to use for the following JMeter/Azure Architecture: https://github.com/ObjectivityLtd/jmeter-kubernetes/wiki/1.-Private-Agent-and-Traditional-Grid
Use it when you want to run JMeter tests with Azure pipelines and either no distributed testing or traditional grid. Infrastructure is privately hosted.

#### Features:
+ JMeter tests run from maven build
+ Test variants are fully managed via user.properties files
+ Trend reports are generated with JMeter reporting feature
+ Optionally JMeter results can be streamed to Azure insights via Azure backend listener: https://github.com/adrianmo/jmeter-backend-azure
+ Azure pipelines are short and extensible based on a included template.
+ Notifications can be sent to Teams channel via webHook
+ Solution has BATS tests (only needed if you plan to customize the project) 


# Requirements to run the solution locally.

JAVA 1.8+ and maven 3.6.3 or maven wrapper.
See here to understand how to run it: https://medium.com/@gabriel.starczewski/running-jmeter-tests-with-maven-and-maven-wrapper-6725aa025bd9

## How to use ?

Please see the video: https://web.microsoftstream.com/video/7f80d403-420d-4ab3-9479-4ac042dd8af6?list=studio
or follow the written instruction below:

You need to fork/copy/import the repo to the one you own and then 

1) Configure the repository 
2) Configure secrets and pipelines in Azure DevOps
3) Attach private build agent to JMeterExecutors pool.


#### Configure the repository

This is achieved by editing .properties files.
Parameters reference can be found ([here](https://github.com/ObjectivityLtd/jmeter_azure_maven_boilerplate/wiki))

Go to  [src/test/jmeter/props/base.user.properties](https://github.com/ObjectivityLtd/jmeter_azure_maven_boilerplate/blob/master/src/test/jmeter/props/base.user.properties)  and provide parameters 

 +  insights_url=https://portal.azure.com/some-insights/overview
 +  instrumentation_key=some_key

Go to  [src/test/azure/azure.properties](https://github.com/ObjectivityLtd/jmeter_azure_maven_boilerplate/blob/master/src/test/azure/azure.properties)  and provide parameters 

+ devops_url=https://dev.azure.com/your_org/
+ user=someuser
+ chatopsWebHook=https://myhook.addres/somedata

#### Configure secrets and pipelines in Azure DevOps

Configure secrets:

Go to your DevOps project Pipelines->Library and create variables group called 'performance-secrets'.
Create a secret variable called 'pat'. The value should be that of your personal access token that needs to have permissions to download build artifacts.
![](https://github.com/ObjectivityLtd/jmeter_azure_maven_boilerplate/blob/master/img/pat.png)
Configure pipelines:

Go to Pipelines -> New Pipeline -> Select your repository and YAML file for pipeline. Save & Run. Repeat for other pipelines.

#### Attach private build agent to JMeterExecutors pool.

In DevOps project click Project Settings -> Agen Pools -> New Pool. Name it JMeterExecutors. Attach the agent by running the command

`docker run -e AZP_URL=https://dev.azure.com/your_org -e AZP_TOKEN=YOUR_PAT AZP_POOL=JMeterExecutors -e AZP_AGENT_NAME=docker_gab gabrielstar/jmeter:2.2`

Note: This can be container instance instead of a bare VM, then the command is

`az container create -g YOUR_GROUP -n jmeter-build-agent --image gabrielstar/jmeter:2.2 --cpu 4 --memory 4 --environment-variables  AZP_TOKEN=YOUR_PAT AZP_URL=https://dev.azure.com/your_orgD AZP_POOL=JMeterExecutors AZP_AGENT_NAME=docker_gab
`

You can start pipeline now.
---

### Write and manage your test

You can extend test.jmx file and use it.
You should externalize your test parameters by placing them in user.properties files.
Optionally configure thresholds.properties.

### More info

Have a look at [Wiki](https://github.com/ObjectivityLtd/jmeter_azure_maven_boilerplate/wiki) for detailed documentation.
