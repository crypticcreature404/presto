<!---
<!DOCTYPE html>
<html>
<head>
    <title>Upload PDF Files</title>

    <link rel="stylesheet" type="text/css" href="assets/css/uploadForm.css">
</head>

<body>
 --->
 <cfset variables.title = "Upload PDF Files">
 <cfset variables.styleIncl = "assets/css/uploadForm.css">
 <cfset deleteOutputFolder=false />
 <cfinclude template="header.cfm">

 <cfset baseSaveDir = appConfig.outputPath > <!--- Use outputPath from config --->

 <!--- Config file existence check. This makes sure you're config data is valid for this process --->
 <cfif not directoryExists(appConfig.outputPath)><h1>Danger! Can't find your configured Output Path from Presto.conf.</h1></cfif>
 <cfif not directoryExists(appConfig.templatePath)><h1>Danger! Can't find your configured Templates Path from Presto.conf.</h1></cfif>




 <cfif isDefined('url.deleteUF')>
 	<cfif url.deleteUF is 1>
  		<cfset deleteOutputFolder = true />
  	</cfif>
 </cfif>

 <cfif deleteOutputFolder>
	 <cfset targetPath = baseSaveDir>

		<!--- Check if the root folder exists --->
		<cfif directoryExists(targetPath)>

		    <!--- List only the top-level items inside the folder (recurse="false") --->
		    <cfdirectory action="list" directory="#targetPath#" name="getContents" recurse="false">

		    <!--- Loop through the found items --->
		    <cfloop query="getContents">
		        <cfset itemPath = targetPath & "/" & name>

		        <cfif type EQ "Dir">
		            <!--- Recursively delete sub-directories and their contents --->
		            <cfdirectory action="delete" directory="#itemPath#" recurse="true">
		        <cfelse>
		            <!--- Delete individual files --->
		            <cffile action="delete" file="#itemPath#">
		        </cfif>
		    </cfloop>

		    <cfoutput>All contents of your output folder have been removed, but the folder remains.</cfoutput>
		<cfelse>
		    <cfoutput>The folder '#baseSaveDir#' was not found.</cfoutput>
		</cfif>
 </cfif>

<!---<h2>Upload PDF Files</h2>--->

<cftry>
<cfdirectory directory="#baseSaveDir#" action="list" name="outputFileList" />
<!--- <cfdump var="#outputFileList#" >
<cfdirectory action="list"
             directory="#expandPath('.')#"
             name="dirOnly"
             type="dir"> --->
    <cfif outputFileList.recordcount gt 0>
       	<h2 style="color:#ff0000;">There are currently directories in your Output folder (<cfoutput>#baseSaveDir#</cfoutput>). You might want to <a href="uploadForm.cfm?deleteUF=1">delete</a> or relocate them to continue.</h2>
	</cfif>
<cfcatch>
	<cfoutput>
	    <h3>An error occurred:</h3>
	    <p><strong>Message:</strong> #cfcatch.message#</p>
	    <p><strong>Detail:</strong> #cfcatch.detail#</p>
	</cfoutput>
</cfcatch>
</cftry>

<form action="processUploads.cfm" method="post" enctype="multipart/form-data">

    <!-- Hidden file input -->
    <input type="file" id="pdfFiles" name="pdfFiles" multiple accept="application/pdf" style="display:none;">

    <!-- Drag-and-drop zone -->
    <div id="dropzone" class="dropzone">
        Drag &amp; Drop PDF files here<br>or click to browse
    </div>

    <div style="text-align:center; margin-top:20px;">
        <strong>Instructions:</strong><br>
        - You can select multiple PDF files at once.<br>
        - After uploading, you'll be able to assign folder names and types for each file.<br>
        <!-- Thumbnail preview area -->
        <div id="previewContainer"></div>

        <br>
        <input type="submit" id="uploadBtn" value="Upload PDFs" disabled>
    </div>
</form>


<script>
    const dropzone = document.getElementById("dropzone");
    const fileInput = document.getElementById("pdfFiles");
    const previewContainer = document.getElementById("previewContainer");
    const uploadBtn = document.getElementById("uploadBtn");

    dropzone.addEventListener("click", () => fileInput.click());

    fileInput.addEventListener("change", () => {
        showThumbnails(fileInput.files);
        toggleUploadButton();
    });

    dropzone.addEventListener("dragover", (e) => {
        e.preventDefault();
        dropzone.classList.add("dragover");
    });

    dropzone.addEventListener("dragleave", () => {
        dropzone.classList.remove("dragover");
    });

    dropzone.addEventListener("drop", (e) => {
        e.preventDefault();
        dropzone.classList.remove("dragover");

        const droppedFiles = e.dataTransfer.files;
        fileInput.files = droppedFiles;

        showThumbnails(droppedFiles);
        toggleUploadButton();
    });

    function showThumbnails(files) {
        previewContainer.innerHTML = "";

        Array.from(files).forEach(file => {
            const url = URL.createObjectURL(file);

            const wrapper = document.createElement("div");
            wrapper.className = "thumb";

            const embed = document.createElement("embed");
            embed.src = url;
            embed.type = "application/pdf";

            const name = document.createElement("div");
            name.className = "thumb-name";
            name.textContent = file.name;

            wrapper.appendChild(embed);
            wrapper.appendChild(name);

            previewContainer.appendChild(wrapper);
        });
    }

    function toggleUploadButton() {
        uploadBtn.disabled = fileInput.files.length === 0;
    }
</script>

<cfinclude template="footer.cfm">
