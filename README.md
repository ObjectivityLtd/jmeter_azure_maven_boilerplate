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


#Requirements to run the solution locally.

JAVA 1.8+ and maven 3.6.3 or maven wrapper.
See here to understand how to run it: https://medium.com/@gabriel.starczewski/running-jmeter-tests-with-maven-and-maven-wrapper-6725aa025bd9

## How to use ?

You need to fork/copy/import the repo to the one you own and then 

1) Configure the repository 
2) Configure secrets and pipelines in Azure DevOps


