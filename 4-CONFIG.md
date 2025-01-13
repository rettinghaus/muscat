# Editor Configuration

The Editor Configurations permit to customize the contents of a Source in view
and edit. See EditorConfiguration model for the internals.

An EditorConfiguration is attached to a Source by parsing its leader, of
falling back to default. Each EditorConfiguration has associated four property
stacks:

*   Rules: cataloguing rules, ex. the default publication state of a new
    Source (not implemented! left for reference).
*   Options: Editor options for each tag in a Source, ex. how many columns a
    text area for editing a tag should be.
*   Labels: Labels for tags and internationalized abbreviations.
*   Layout: Which tags to show in edit/view

### Default configuration

The default behaivour of the EditorConfiguration is loaded from YAML files in
`config/editor_profiles/default/profiles.yml`. This file contains a list of
configuration stacks, eg:

    ---
    - :id: DefaultCH
      :name: Default (CH)
      :labels:
      - BasicLabels
      :rules:
      - BasicCataloguingRules
      :options:
      - BasicFormOptions
      :layout:
      - LayoutDefaultCH
      :filter:
        default: true

This example configures the default fallback. The main elements are:

*   `id` - a string identification used internally (no spaces)
*   `name` - The name shown in the web page
*   `labels` - an array containing a list of YAML files from which to load the
    label configuration
*   `rules` - as above, but for rules
*   `options` - idem, for the options
*   `layout` - idem, for the layout
*   `filter` - Specifies the filter to see which Sources should be shown with
    this stack. Refer to EditorConfiguration for more details.

Each of the YAML files above (in the list without .yml extension) will be
searched in config/editor_profiles/default/default/configurations/

### Configuration customization

The default files do not need to be modified directly. Instead it is possible
to put all customizations in a user-specified dir into config/editor_profiles.
This directory is configured in RISM::EDITOR_PROFILES in application.rb, for
example RISM::EDITOR_PROFILES="ch" will set config/editor_profiles/ch/ as the
custom config dir.

If config/editor_profiles/ch/profiles.yml is present, it will OVERRIDE
COMPLETELY the default one in config/editor_profiles/default/profiles.yml. The
files in configurations/ on the other hand are overlayed: this means that if a
file with the same name exists in default/configurations/ and
RISM::EDITOR_PROFILES/configurations/, the contents of the two will be merged
together. In this way, a completely new configuration can be made, or just a
small piece can be overridden (eg. this is handy in labels).

### Configuration

On opening the display/edit of a Source, the EditorConfigurations are cycled:
if one matched the `filter[leader]` or `filter[tag]`, it will be used for
displaying/editing of that manuscript. If none is found, the configuration
with `filter[show]` (for displaying) or `filter[default]` (for editing) will
be used. Refer to EditorConfiguration for the configuration of :filter.

The first setting in the configuration should be the `group_order`, which
specifies the display order of the various display/edit groups.

    --- !map:Settings 
    group_order: 
    - control
    [snip...]

	So the EditorConfiguration that is loaded will be the first one that matches
the Source leader, or the first one that is default. Once it is selected, all
the other staks are loaded. Each stack can specify one or more YAML files, but
generally Rules, Options and Labels are shared between all views.

## General formatting rules for the embedded YAML data

Do not use tabs. Use 2 spaces for each level of indentation. Mismatched
indentation is a common source of bugs.

Lists always start on the next line (below the element name) and are lined up
with the beginning of the element name. Each member of a list is prefixed with
"- " (a dash followed by a space) e.g.:

    --- !map:Settings
    groups:
      dates:
        all_tags:
        - "033"
        - "518"

		To override an element from a configuration higher up in the stack simply
set the element to the desired value. Stacking is non-destructive. For
example:

config A:

    --- !map:Settings
    "123":
      label: A label
      role_at_least: "administrator" 

config B:

    --- !map:Settings
    "123":
      label: B label

	

Config B is further down in the stack and so is applied later meaning the tag
will ultimately use the label "B label". However, the tag will still be
restricted to administrator access as config B did not override that value and
omitting it does not remove it.

## Rules

They are the basic cataloguing rules, this is the default configuration: 	
    --- !map:Settings 
    cataloguer: 
      published_state_after_save: unpublished
      published_state_after_create: unpublished

	At the top level a Rules configuration may contain one of these three
elements in addition to its normal settings:

*   cataloguer
*   editor
*   administrator

Settings within the above sections will only apply to the named role. Any
setting not in these groups (i.e. at the top level with no indentation) will
be applied globally (to everyone).

*   published_state_after_create: <wf_stage value>
*   published_state_after_save: <wf_stage value>

## Labels

Labels for tag field/subfield names and group names must be quoted wherever
they are used, e.g. "001", "100", "789", "a", "4", etc.

*   label: <label text>
*   accepts: <LIST of tag names>

Example:

    --- !map:Settings 

    "doc_abbreviations": !map:HashWithIndifferentAccess 
      label: !map:HashWithIndifferentAccess 
        de: "Abkürzungen"
        en: "Abbreviations"
    028: !map:HashWithIndifferentAccess 
      label: !map:HashWithIndifferentAccess 
        it: Numero dell'editore
        fr: "Numéro d'éditeur"
        de: Verlagsnummer
        en: Publisher Number
      fields: !map:HashWithIndifferentAccess 
        a: !map:HashWithIndifferentAccess 
          label: !map:HashWithIndifferentAccess 
            it: Numero di lastra
            fr: "Numéro de plaque"
            de: Plattennummer
            en: Plate number
    "100": !map:HashWithIndifferentAccess 
      label: !map:HashWithIndifferentAccess 
        it: Compositore/Autore
        fr: Compositeur/Auteur
        de: Komponist/Autor
        en: Composer/Author
      accepts: 
      - "700"
      fields: !map:HashWithIndifferentAccess 
        a: !map:HashWithIndifferentAccess 
          label: !map:HashWithIndifferentAccess 
            it: Nome
            fr: Nom
            de: Name
            en: Name

Example:

    --- !map:Settings 
    "000": 
      tag: tag_no_subfield
      tag_params: 
        editor_only: true
      tag_header: none
    "001": 
      tag: tag_no_subfield
      tag_params: 
        read_only: true
      tag_header: none
    "110": 
      layout: 
        fields: 
        - - a
          - type: institution
            editor_partial: subfield_secondary
            cols: 2
        - - b
          - cols: 1
        columns: 3

		
## Layout:

At the top level a Layout contains settings that pertain to the overall
layout:

*   arrange: <"columns" or "list" or "tabs">
*   single_column_order: <"riffle" or "append">
*   group_order: <LIST of group names>
*   groups: <NESTED LAYOUT CONFIGURATION>

The groups: section defines the groups of tags that will run together in the
form. These groups may materialize as panels or tabs etc. depending on the
layout template used. Each element in groups is a named group (containing only
lowercase letters and underscore). This name is referred to by the group_order
layout setting. Within each of these named groups a number of settings are
available:

*   label: <label text>
*   all_tags: <LIST of tag names>

Example:

    groups: 
      group_administration: 
        all_tags: 
        - "000"
        - "001"
        - "003"
        - 008
        - "040"
        - "599"
        admin_only: true
      group_linking: 
        all_tag_templates: 
          "775": show_related_editions
        all_tags: 
        - "775"
      group_works: 
        all_tag_templates: 
          "600": show_work
        all_tags: 
        - "600"

