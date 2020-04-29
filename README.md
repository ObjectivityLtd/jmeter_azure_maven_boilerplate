# jmeter_azure_maven_boilerplate

This is a boilerplate project to use for the following JMeter/Azure Architecture: https://github.com/ObjectivityLtd/jmeter-kubernetes/wiki/1.-Private-Agent-and-Traditional-Grid
Use it when you want to run JMeter tests with Azure pipelines and either no distributed testing or traditional grid. Infrastructure is privately hosted.

#### Features:
+ JMeter tests run from maven build
+ Test variants are fully managed via user.properties files
+ Trend reports are generated with JMeter reporting feature
+ Optionally JMeter results can be streamed to Azure insights via Azure backend listener: https://github.com/adrianmo/jmeter-backend-azure
+ Azure pipelines are short and extensible based on a included template.
+ Notifications can be send to Teams channel via webHook
+ Solution has BATS tests (only needed if you plan to customize the project) 


## How to use ?

First, please prepare the following information:


