README 

Used for DO development project.
Script by Shawn Rynearson For Karen Eilbeck
shawn.rynearson@gmail.com

** README and shell script created by Shawn Rynearson <shawn.rynearson@gmail.com>
   Additional comments and some modification to Mark Singleton scripts were made by Shawn Rynearson.

** CVDO.sh will create a file called CVDO, there are additonal scripts to preform other tasks noted 
   at bottom 

** See DOC file for steps preformed after shell script was ran for CVDO, and methods used for OBO-Edit 
   as well as overall development of CVDO.

** Must have a bin and data directory, if not working in /trunk.  All perl and .sh script go in bin.  
   MeSH.xml file go in /data.  Additionally, reference xref files go in /data.

** Currently the XML_Parser will output only C14 values.  
   When building a different disease ontology, changes will have to be made throughout the scripts,
   would suggest doing a grep command for: C14 and cardiovascular, etc, to find needed changes. 



 START OF CVDO.sh STEPS.

************************************************************************************************
** Steps of XML Parsering **
************************************************************************************************

* Checked the output of C14 totals, and programs work correctly.
* When cleaning up the scripts I discovered that I only needed two of Mark's scripts. 
  Karen has copies of all of them (if needed) on an external hard drive.

************************************************************************************************
** Steps of Tree_Generator  **
************************************************************************************************

./GO_Traverser.pl
* Uses go-perl to traverse ontology tree and outputs each terms name, acc number, and parent. 
* This script has three different options.

./Tree_Dup_Remover.pl
* The above script generates many double parents, Returns three file types: Unique list, dup list and report

./Tree_Uniq_Reporter.pl
* Uses Unique output and allows you to isolate the parents who have two or more unique parents.

************************************************************************************************
** Steps of Xref_Add_MeSH.sh  **
************************************************************************************************

./Xref_Term_Parser.pl
* Take reference obo file and collect all xrefs terms.  Outputs them as a total list.

./Xref_Iso_Diease.pl
* Takes above output and isolate only terms with CVDO accession numbers.

./Xref_Combine.pl
* Creates two data structures which have the CVDO accession numbers as keys to references.
  Hash::Merge combines the two data structures base on accession numbers. To create on large file 
  Containing MeSH data with xrefs.

./Xref_Formatter.pl
* Reformats to obo file specs.

./Xref_Final
* Uses a series of substitutions and organizes the xref correctly. The output is the final obo file, which 
  Can be loaded into OBO-Edit.

./Tree_Sum_Nodes.pl
* Generates a table similar to figure 4 of Karen's grant proposal.

************************************************************************************************
******* Optional scripts ******
************************************************************************************************

./OBO_Cleanup.pl
* Used to clean up the order of the names in ontology.  If using ./Gene_Merge.pl and Xref_Gene_transitivity.pl 
  this script is not needed.

./Name_Match.pl
* Script takes fma PATO, and CVDO file and matches single words which exist in both ontologies.
* Currently only collect fma terms because PATO had no matching terms.
* This helps to build relationships.

./Gene_Merge.pl
* Take working ontology and adds Omi file.  Omi file is name based not acc number so there
  is a room for improvment here.

./SNOMED_Presence.pl
* Takes obo file and outputs term without SNOMED id's.
  missing id's need to be added manually.

./OBO_Link_Crawler.pl
* Collect http links from obo file and checks functionality.

./Xref_Gene_transitivity.pl
* Takes working obo file and output gene transitivity through ontology.

./HGNC_Gene_Builder.pl
* Collects genes listed in xref: and matches them to HGNC file and 
  and HGNC id's and name, in addition to gene description.
* Before running this program, ran a perl command to change xref's from gene:## to HGNC_gene:##, and transitive_HGNC_gene.
  required change for match to work. 
  
