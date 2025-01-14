# Importing MARC records into the application

Marc records can be imported into muscat. They can be fed and imported using
the command line script:

    rails runner housekeeping/import/import_from_marc.rb $FILE $MODEL

Records for thesaurus models like Places, StandardTerms etc., which are not
related to marc, should be imported first with:
    rails runner housekeeping/import/import_thesaurus_from_marc.rb $File

	`$FILE` contains all the Marc records in MarcXML format. `$MODEL` refers to
the model of the records (e.g. Source, Person etc.)

How the Marc records, tags and subfields are interpreted bye the software id
controlled in `config/marc/tag_config.yml`. In Particular, tags like 100 or
the 700, are linked to specific data into foreign tables in the database (to
build up autority files). For example, the 100 Name tag is related to the
Person object, and when importing a Person having the same name as in $0 is
looked up. If the entry does not exist, it will be created (along with
life_dates from $d).

The import itself is logged by a daily rotated log/import.log

### Authority files

During the import, all fields with a $0 (100, 240, 852), this value will be
used to check if the entry already exists in the database. It means that for
People values, the same name with a different $0 will generate a duplicate
(which is the expected behavior since we can have people with the same name).
With other authorities, duplicates will cause the import to fail since
duplicates are not allowed. The data should be checked before the import.

For imported fields without $0, a match will be search on the other fields
(name, dates, etc.).

For the StandardTitle authority, fields without a $0 (e.g., 740) can create
problems during the import if a StandardTitle without $0 (740) is imported
before a value with a $0 (e.g., 240). The first one will cause a new ext_id to
be generated which will then cause a duplicates validation error with the one
with the ext_id. The fix is either to temporarily allow duplicates in the
StandardTitle class, or to add a $0 value to the 740 field to the data to be
imported.

## Importing from XML data

XML data can be converted to text MARC using an xsl2 stylesheet in
housekeeping/import/housekeeping/import/marcxml2marctxt.xsl. In this example
Saxon HE version 9 is used
(http://sourceforge.net/projects/saxon/files/Saxon-HE/), which requires a java
runtime to be installed:

    java -jar saxon9he.jar -s:input.xml -xsl:$MUSCAT_DIR/housekeeping/import/marcxml2marctxt.xsl -o:output.marc

The XML file has to be well formed, and use the correct namespace:

    <collection xmlns="http://www.loc.gov/MARC21/slim">

The MARC data can then be imported using the conventional importer.
