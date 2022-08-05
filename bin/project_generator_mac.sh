#!/bin/bash

answerColour='\e[0;32m' #green
echoColour='\e[0;33m'   #yellow
questionColour='\e[0;36m' #blue
NC='\e[0m' # No Color

cd ..

TOOL_HOME=$(pwd)
RESOURCE_PATH=$TOOL_HOME/resources
CONF_FILES_PATH=$TOOL_HOME/conf/
CONNECTOR=n
CONDITION=y


echo -e "${questionColour}Provide the project location you want to create the project.${answerColour}"
read projectLocation
echo -e "${NC}"

cd $projectLocation

echo -e "${questionColour}Provide the integration name(name of the git repository.${answerColour}"
read newProjectName
echo -e "${NC}"

#git checkout develop

echo -e "${questionColour}Provide the project version.(Default project version is 1.0.0-SNAPSHOT)${answerColour}"
read projectVersion
echo -e "${NC}"

if [ -z "$projectVersion" ]
then
	projectVersion="1.0.0-SNAPSHOT"
else
	projectVersion=$projectVersion
fi

echo -e "${echoColour}Project version is $projectVersion${NC}"

echo -e "${questionColour}Provide the project group id(Default project version is com.middleware).${answerColour}"
read projectGroupId
echo -e "${NC}"

if [ -z "$projectGroupId" ]
then
	projectGroupId='com.middleware'
	echo -e "${echoColour}Default Project group id added. $projectGroupId${NC}"
else
	projectGroupId=$projectGroupId
fi

while true; do
    read -p "Do you wish to create Connector Exporter project?" yn
    case $yn in
        [Yy]* ) CONNECTOR=y; break;;
        [Nn]* ) break;;
        * ) echo "${echoColour}Please answer y or n.${NC}";;
    esac
done

exporterProject=${newProjectName}DockerExporter
compositeProject=${newProjectName}CompositeExporter
configProject=${newProjectName}Configs

if [ "$CONNECTOR" = "$CONDITION" ]
then
   ConnectorProject=${newProjectName}ConnectorExporter
   cp $RESOURCE_PATH/pom.xml .
   sed -i '' "s/varConnectorProject/$ConnectorProject/g" pom.xml
   mkdir ${ConnectorProject}
   
else
   cp $RESOURCE_PATH/pom.xml .
fi


sed -i '' "s/varCompositeProject/$compositeProject/g" pom.xml
sed -i '' "s/varConfigProject/$configProject/g" pom.xml
sed -i '' "s/varExporterProject/$exporterProject/g" pom.xml
sed -i '' "s/varProject/$newProjectName/g" pom.xml
sed -i '' "s/varVersion/$projectVersion/g" pom.xml
sed -i '' "s/varGroupId/$projectGroupId/g" pom.xml

cp $RESOURCE_PATH/.project .
sed -i '' "s/varProject/$newProjectName/g" .project

mkdir ${exporterProject}
mkdir ${compositeProject}
mkdir ${configProject}

#DockerExporter project

cd ${exporterProject}
cp -r $RESOURCE_PATH/DockerExporter/. .
mkdir CompositeApps
mkdir CarbonHome
mkdir Libs
mkdir Resources

sed -i '' "s/varExporterProject/$exporterProject/g" pom.xml
sed -i '' "s/varVersion/$projectVersion/g" pom.xml
sed -i '' "s/varGroupId/$projectGroupId/g" pom.xml
sed -i '' "s/varCompositeProject/$compositeProject/g" pom.xml
sed -i '' "s/varProject/$newProjectName/g" pom.xml

sed -i '' "s/varExporterProject/$exporterProject/g" .project


#Config project
cd ../${configProject}

mkdir -p src/main/synapse-config

cd src/main/synapse-config
mkdir api
mkdir endpoints
mkdir inbound-endpoints
mkdir local-entries
mkdir message-processors
mkdir message-stores
mkdir proxy-services
mkdir sequences
mkdir tasks
mkdir templates
	
cd ../../../
cp -r $RESOURCE_PATH/EIConfigs/. .

  
sed -i '' "s/varConfigProject/$configProject/g" pom.xml
sed -i '' "s/varVersion/$projectVersion/g" pom.xml
sed -i '' "s/varGroupId/$projectGroupId/g" pom.xml
sed -i '' "s/varProject/$newProjectName/g" pom.xml

sed -i '' "s/varConfigProject/$configProject/g" .project

#Composite exporter project

cd ../${compositeProject}
cp -r $RESOURCE_PATH/CompositeExporter/. .

sed -i '' "s/varCompositeProject/$compositeProject/g" pom.xml
sed -i '' "s/varVersion/$projectVersion/g" pom.xml
sed -i '' "s/varGroupId/$projectGroupId/g" pom.xml
sed -i '' "s/varProject/$newProjectName/g" pom.xml

sed -i '' "s/varCompositeProject/$compositeProject/g" .project

####################
if [ "$CONNECTOR" = "$CONDITION" ]
then
   
   #Connector exporter project

   cd ../${ConnectorProject}
   cp -r $RESOURCE_PATH/ConnectorExporter/. .

   sed -i '' "s/varConnectorProject/$ConnectorProject/g" pom.xml
   sed -i '' "s/varVersion/$projectVersion/g" pom.xml
   sed -i '' "s/varGroupId/$projectGroupId/g" pom.xml
   sed -i '' "s/varProject/$newProjectName/g" pom.xml

   sed -i '' "s/varConnectorProject/$ConnectorProject/g" .project
   
else
   cd ../
   sed -i '12d' pom.xml
fi
######################