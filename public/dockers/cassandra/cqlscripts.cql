cqlsh -e "create keyspace drillix with replication = {'class':'SimpleStrategy','replication_factor':3};"
cqlsh -e "create table drillix.events (eventuuid uuid PRIMARY KEY,requestuuid uuid,tenantid uuid,dataset text,fields map<text,text>);"
