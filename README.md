# Openshift OpenLiberty s2i builder image

Used to build openliberty docker images with openshift from source code.
Expects the the following format from the source code run against:

pom.xml -> maven build file
target/app.war -> output war artifact
