# markdown_table_formatter
gawk - Skript to format tables in markdown documents

## Usage

```
 cat original.md | gawk -f format_table.awk > formatted.md
```

## Goals

* Format tables within the Markdown-File into a readable table.
* leave the rest of the document unchanged
* leave tables with formatting errors unchanged and print the error reason to STDERR

## Examples

### Reformat

Convert from :

```
|header1|header2|header3|
|--:--  |:-----|------:|
|center 1|left 1|right1|
|c2|l2|Very long text to see the effect|
|c3|l3|r3|
```

to:

```
|  header1 | header2 |              header3             | 
|-----:----|:--------|---------------------------------:| 
| center 1 | left 1  |                           right1 | 
|    c2    | l2      | Very long text to see the effect | 
|    c3    | l3      |                               r3 |
```

### Errors:

If the formatter finds an error in a source markdown table, this table will be written into the destination without any changes.
Errormessages will be written to STDERR. 

```
$> cat test_table_def.md  | gawk -f ../format_table.awk > result.md

Line: 9 : Line does not End with Pipe-Symbol
```


