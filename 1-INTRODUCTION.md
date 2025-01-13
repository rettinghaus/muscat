# Muscat Introduction

**muscat** is a framework for cataloging music documents (handwritten and
printed music scores). It is a Rails application that provides facilities for
creating and managing Marc21 records with a focus on music. The project was
initiated by the United Kingdom working group of the Répertoire International
des Sources Musicales (RISM) and then developed further by the Swiss working
group. It is released as an open-source project.

## Source code and further documentation

The source code is available on GitHub https://github.com/rism-ch/muscat

The cataloguing guidelines submodule is also available on GitHub
https://github.com/rism-ch/muscat-guidelines

The documentation for version 1.0 and 2.0 (legacy) is available at
http://docs.rism-ch.org/muscat/1.0/

## Application structure

The basic entity in muscat is the Source class, which describes a single
source. The Marc21 data is stored directly in the database, and is parsed to a
Marc object with holding MarcNodes recursively. A MarcNode is a field at the
first level of recursion and a subfield at the second level. Relevant
information (such as author name) is also extracted from the Marc record and
stored in the same database row. A the same time, a Source is put in relation
with the authority data, or foreign classes, stored directly in the database.
The foreign classes representing data are:

*   People (Contributors)
*   Institutions
*   StandardTerms
*   StandardTitles
*   LiturgicalFeasts
*   Catalogues
*   Places

This way all the basic information related to a Source is always available on
the database. Marc21 records and these classes are automatically kept in sync,
using ids to relate the various entities.

The web interface is a standard Rails 4 application following the MVC
paradigm.

Full-text search on the data is handled using the Solr full-text index. Every
time a Source is saved, relevant data is extracted and sent to the index.

How the Marc21 data is managed, and how the interaction between Marc records
and database-stored elements is configured in the tag configuration, in
`config/marc/tag_config*.yml`, one for each model that supports Marc. This
also defines how records should be handled by the system (for example, if a
tag is repeated).

The behavior of the show/edit pages for Marc records is controlled in the
config/editor_profiles directory, using the EditorConfiguration, which, on the
base of the MarcConfig (described above), decide which/how tags are shown or
edited.

