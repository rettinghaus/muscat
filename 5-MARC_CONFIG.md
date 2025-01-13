# MARC structure, configuration and indexing

Please note: this document is still incomplete

## Introduction

The Marc data handling resides into two classes: Marc and MarcNode. The Marc
class represents a full marc record, for ex:

    =000  00000ncm a22001817  4500
    =001  20040806000001
    =035  ##$a(Uk)004503318
    =003  Uk
    =005  20110523122820.0
    =008  930323s1596 be ||z n ita
    =040  ##$aUk$beng$cUk
    =041  ##$aita$gita
    =245  00$aMadrigali a otto voci /$cDe diuersi eccellenti et famosi autori. Con alcuni dialoghi, & echo, per cantar & sonar à due chori. [...]
    =260  ##$aIn Anuersa :$bappresso Pietro Phalesio$c1596
    =300  ##$a8 part books ;$c16 x 21 cm (obl. 4to)
    =500  ##$aWith a dedication by the publisher to Pierre François Sweerts in Italian, signed ’20. di Luglio 1596’
    =510  4#$aRISM B/I$c1596 ⁸
    =650  #0$aMadrigals, Italian$vParts
    =700  1#$aPhalèse, Pierre$db. ca. 1510$eprinter
    =700  1#$aSweerts, Pierre François$d1567-1629$ededicatee
    =700  1#$aVecchi, Orazio$d1550-1605$ecomposer
    =752  ##$aBelgium$dAntwerp
    =852  41$aGB Lbl$pA.234$qCopy at A.234. Imperfect: the tenor part book only

When the Marc class is loaded, each line is parsed and attached to a MarcNode.
In turn, all the elements in a single marc tag are again parsed into marc
nodes. For example, this line in the marc data:

    =700  1#$aVecchi, Orazio$d1550-1605$ecomposer

Is expressed as

    MarcNode tag = 700
     children:
        MarcNode tag = a, content = Vecchi, Orazio
        MarcNode tag = d, content = 1550-1605
        MarcNode tag = e, content = composer

Both Marc and MarcNode provide functions to navigate, search, add or delete
the single tags or subtags.

## Configuration
The configuration for each model that supports marc is in
config/marc/tag_config_<modelname>.yml. To support local overrides for
specific installations, an override file can be in each RISM::MARC
subdirectory, for example config/marc/a1 or config/marc/ch. It has to be
called local_tag_config_<modelname>.yml and it will be loaded automatically if
present. The tag configuration contained overrides completely each tag (see
more later) This is an excerpt from the configuration file:

    "041":
      :master: a
      :indicator: ["0#", "1#"]
      :occurrences: "*"
      :fields:
      - - a
        - :occurrences: "*"
      - - d
        - :occurrences: "*"
      - - e
        - :occurrences: "*"
      - - g
        - :occurrences: "*"
          :no_browse: true
      - - h
        - :occurrences: "*"
    "100":
      :master: "0"
      :indicator: "1#"
      :occurrences: "?"
      :fields:
      - - "0"
        - :occurrences: "?"
          :foreign_class: Person
          :foreign_field: id
          :no_show: true
      - - a
        - :occurrences: "?"
          :foreign_class: ^0
          :foreign_field: full_name
      - - d
        - :occurrences: "?"
          :browse_inline: true
          :foreign_class: ^0
          :foreign_field: life_dates
          :foreign_alternates: alternate_dates
      - - j
        - :occurrences: "?"

The configuration specifies the basic elements of a tag, in particular the
subfield and if it is repeatable, in this format:

*   0 (none. used only to keep tag/subtag configurations that are unused and
    therefore discarded on import)
*   ? (none or one. this subtag need not be present, but at most only one
    occurance may exist)
*   1 (one occurance must exist. no more than one is allowed)
*   + (one or more must exist.  at least one occurance must be present, more
    occurrences are allowed)
    *   (none or more. none, one or many may exist)

The no_browse indicates that it is not displayed in the web page when showing
or editing. The 100 tag example shows how to attach a DB model to a particular
tag. The "master" tag is the MARC tag that holds the foreign key to the
relation, in this example the database ID. foreign_class and foreign_field
respectively are the model and the remote field. The other two fields use the
same principle to connect two fields that are then cashed in the fields
indicated from foreign_field in the DB table. Since occurrences is "?" they do
not need to be present. Marc data has the precedence on data in the db, this
means that the db is updated on the basis of the Marc data. The Marc class
will attempt to write to the db each time .save() is called on the model. This
can be disabled with the appropriate trigger in the model to which marc is
attached. If the data pointed to by $0 does not exist a fresh new DB record
will be created based on the configured marc data. This is used when importing
to populate the Authority files on DB. When Marc data is loaded this
information is used to create objects in memory pointing to the models
configured by each single tag. In this case if the master tag is not present
or points to an invalid db reference, the loading of the Marc record will stop
with an error.

