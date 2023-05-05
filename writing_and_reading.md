# Writing and Reading manuscripts


## Citation management with Zotero
Zotero is an open source citation management software.
You can get add-ons for browsers such as Chrome and mobile devices (iOS and Android) that enable you to save citations while seaching the web.
There are also plugins for document editing software (Word, Google Docs, text editors such as Atom) that enable you to insert citations into manuscripts easily.

There are also plugings for Zotero itself that can be helpful. One such plugin is the BetterBibText (BBT) (https://retorque.re/zotero-better-bibtex/).
In the settings I use ```auth.lower + shorttitle(3,3) + year``` as the format for the citation keys.
The BBT plugin can also be used to automatically export a library each time the library is updated in some way. See this link for details (https://retorque.re/zotero-better-bibtex/exporting/auto/)

Another good plugin is Zotfile which can change the file paths of the saved pdfs Zotero stores. Rather than saving them with non-identifiable names they can be saved using the author and title of the reference. (see:http://zotfile.com/)

# Zotero javascript code for batch replacing text in title
1) you must have the entries that you want to replace text in selected (highlighted) in the Zotero GUI
2) Go to Tools--> Developer--> Run JavaScript and paste the following script (modified from: https://forums.zotero.org/discussion/78501/possible-to-search-replace-a-character-in-all-titles) in the text box.
Note: the below example is for italicizing a Genus and species name in the title field of a Zotero entry but can be modified for different circumstances
```
zoteroPane = Zotero.getActiveZoteroPane();
items = zoteroPane.getSelectedItems();
var result = "";
var oldValue = " Acinetobacter baumannii ";
var newValue = " <i>Acinetobacter baumannii</i> ";
for (item of items) {
    var title = item.getField('title');
    result += "   " + title + "\n";
    var new_title = title.replace(oldValue, newValue);
    result += "-> " + new_title + "\n\n";
    item.setField('title', new_title);
    await item.saveTx();
}
return result
```
3) make sure the run as asynch function checkbox is selected and click the Run button


# postscript for BBT keeping italicized words the same case
```
if (Translator.BetterBibLaTeX) {
  if (item.title) this.add({ name: 'title', value: item.title.replace(/<i>/g, '<i class="nocase">' )});
}
```
Note: Just make sure that your exported library matches the id given for the Translator.id value

### Saving and archiving with github and box

#### common git commands
Initialize a new repository:
```git init```

Add files to the next commit:
```git add```

Commit files:
```git commit -m "descriptive message goes here"```

Push commits from the local repository to the remote repository
```git push -u origin master```


#### gitignore files

I like to use this file to do the opposite of what is intended (i.e. to un-ignore files). To do that you have to first ignore all files and then un-ignore specific files of your choosing.

To do that follow the syntax below for the ```.gitignore``` file:

```
* # this line ignores all files
!Directory1/fileA.txt
!Directory2/fileA.txt
!Directory2/fileB.txt
!Directory2/fileC.txt
!Directory3/fileA.txt
!*/ # this line is necessary if the files you specifiy are in subdirectories
```

Note files that are already tracked by Git are not affected by a gitignore file so it is best to create this file before working on your project.


## Saving files using rclone

to set up rclone for a a desired cloud service use (or to regenerate an expired token):

``` rclone config ```

to make a brand new box file with the specified name
``` rclone copy --create-empty-src-dirs -P /local/directory remote:new_directory/ ```

to list all the files of a specific remote path:
```rclone ls remote:path```

to copy a local directory to a remote cloud storage location:

``` rclone copy /local/path remote:path ```

to synch a local directory to a remote cloud storage location:

```rclone sync -i /local/path remote:path ```

The difference between copy and synch according to the documentation is that ```rclone copy``` is used to copy files from source to destination, skipping already copied. Whereas ```rclone sync``` makes the source and destination identical, modifying destination only. I prefer to use the ```rclone copy``` command just in case there is an older file that I happen to delete locally, then it will still be available in the cloud if I need to access it again for some reason.

for more info see the rclone documentation (https://rclone.org/)

## simple script to push to github and save via rclone to a cloud service
I like to put one of these shell scripts in the top level directory for each project I work on.
It will sequentially push specified files to github and then copy all the files to the box. 
The first copy to the box will be the longest, but subsequent copies will only transfer new or edited files er the ```rclone copy``` functionality.
I name it ```backup.sh``` and typically run it anytime I would normally push commits to github whether that is after significant edits within a directory, important edits, or at the end of the day when working on a project.

```
#!/usr/bin/env sh

git push -u origin master
rclone copy -v . box_ucdavis:ClusterSearch

```


# Reading books and papers on Kindle
The following software (linked here: https://www.willus.com/k2pdfopt/
) may be beneficial if you want to read papers or books on a kindle instead of on the computer.

# Writing a paper with markdown

### Markdown template

```
---
title: "**Title goes here**"
date: "date-goes-here"
author:
- Author 1
- Author 2
output:
 #word_document:
 #reference_docx: ./style1.docx
  pdf_document:
    fig_caption: yes
    keep_tex: yes
    latex_engine: pdflatex
 #html_document:
    #df_print: paged
mainfont: Georgia
fontsize: 12pt
geometry: margin = 1in
header-includes:
- \usepackage{setspace}\doublespacing
- \setlength\parindent{24pt}
bibliography: /path/to/Zotero/library.bib
csl: path/to/reference_style.csl
---
\setcounter{page}{1}
\newpage
# Abstract

# Methods

# Results

\newpage
![](path/to/figure.png){ width=100% }

**Figure 1** Figure legend text goes here

```

Once you are done editing your markdown file you can "knit" it from the command line using the following command:
``` Rscript -e "rmarkdown::render('path/to/file.Rmd', output_format= 'all')" ```

Note: by specifying ```output_format='all'``` then each output listed in the ```.Rmd``` file will be created. Otherwise only the first listed output will be made

Additionally, in order to keep your Zotero library file continually updating you can use the BetterBibtex plugin mentioned above.

# Markdown cheatsheet

```
# Heading 1
## Heading 2
### Heading 3
#### Heading 4
*italics*
**bold**

* List item 1
* List item 2

1. Numbered list item 1
2. Numbered list item 2
```
