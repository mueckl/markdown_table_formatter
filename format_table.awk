function a_center( str, n    ,_left,_right )
{ _right = int((n - length(str)) / 2);
  _left = n - length(str) - _right;
  #debug("center right=" _right " left=" _left "  all=" n "  String=" str);
  return sprintf( "%" _left "s%s%" _right "s", "", str, "" )
}
function a_right(str, n){
  return sprintf("%" n "s",str);
}
function a_left(str ,n){
  return sprintf("%-" n "s",str);
}
function align(str , n , a){
   if (a=="c") return a_center(str,n);
   if (a=="r") return a_right(str,n);
   else
   return a_left(str,n);
}
function max(a,b){
   if (a>b) return a;
   else return b;
}
function trim(str){
 return gensub(/^[ \t]+|[ \t]+$/, "", "g",str);
}
function parseAlign(str){
     if (""!=gensub(/[: -]/,"","g",str)){
       addError("Alignment must only contain Dash (-) and Colon (:) Chars");     
       return "x";
     }
     if (0==index(str,"-")) {
       addError("Aligment must contain a dash (-)");
       return "x";
     } 
     if (1!=length(gensub(/[^:]/,"","g",str))){
       addError("Alignment must contain exactly one colon-char (:)");
     }
     
     # hope only good stuff left 

     pos = index(str,":");
     if (pos==1) return "l";
     if (pos==length(str)) return "r";
     return "c";
}
function debug(str){
 #return "";
 #print "log: " str;
}
function eprint(str){
 print str >> "/dev/stderr";
}

function start_table(){
 if (table_started==0) {
   table_started=1;
   table_formated="";
   table_raw="";
   table_error="";
   table_has_errors=0;
   table_row=0;
 }
 else {
   ## next table line
   debug("next Line")
 }
 table_row++;
 if (length(table_raw)==0) {
   table_raw=$0
 } else {
 table_raw=sprintf("%s\n%s",table_raw,$0);
 }
}

function stop_table(){
 if (table_started==1) {
   if (table_has_errors==1){
      eprint(table_error)
      print table_raw;
   } else {
      formatTable();
   }
   table_started=0;
   table_row=0;
 } 
}

function formatTable(){
  # Header Line
  printf("| ");
  for (key in header){ 
    if (key==1) continue;
    printf("%s | ",a_center(header[key],maxlen[key]));
  }
  print ""

  # alignment Line
  printf "|"
  for (key in alignment) {
    if (key==1) continue; # skip Column 1
    printf("%s|",gensub(/ /,"-","g", align(":", (2 + maxlen[key]) , alignment[key]) ));
  }
  print " "

  # Content
  for (i=0;i<content_row;i++) {
  printf ("| ");
    for (j=2;j<headersize;j++){
      printf("%s | ",align(content[i,j],maxlen[j],alignment[j]))
    }
    print "";
  }


  delete alignment;
  delete maxlen;
  delete header;
  delete content;
  headersize=0;
  content_row=0;

}

function addError(str) {
 table_has_errors=1;
 table_error=sprintf("%s\nLine: %d : %s",table_error,NR,str);
}

BEGIN{
content_row=0; FS="|";
headersize=0;
table_started=0;
table_formated="";
table_raw="";
table_error="";
table_has_errors=0;
table_row=0;
}

/^[\|]/{
  debug("table Line");
  start_table();
  # Line not ending with Pipe-Symbol --> Error
  if (0==match(trim($0),"[|]$")) {
    addError("Line does not End with Pipe-Symbol");
  }
  if (table_row==1) { # Header Line
    headersize=NF;
    for (i=1;i<NF;i++){
      header[i]=trim($i);
      maxlen[i]=length(trim($i))
    }
  } else if (table_row==2) { 
    if (headersize!=NF) {
      addError("Number of Fields do not match Headerline");
    };
    for (i=2;i<NF;i++) {
      alignment[i]=parseAlign(trim($i));
    }
  } else { # Content Rows
    if (headersize!=NF) {
      addError("Number of Fields do not match Headerline")
    }
    for (i=2;i<NF;i++) {
      content[content_row,i]=trim($i);
      maxlen[i]=max(length(trim($i)),maxlen[i]);
    }
    content_row++;
  }

}

/^[^|]/{
debug("not table Line");
stop_table();
print
}
/^$/{ # empty Line
debug("empty Line")
stop_table();
print
}
END {
stop_table();
}
