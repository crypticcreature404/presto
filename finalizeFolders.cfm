<cfinclude template="header.cfm">

<cfset uploadDir = expandPath("./tempUploads/")>
<!---<cfset baseSaveDir = expandPath("./pdfStorage/")>--->
<cfset baseSaveDir = appConfig.outputPath > <!--- Use outputPath from config --->
<cfset folderList = ""> <!--- To keep track of created folders --->

<!--- Ensure base directory exists --->
<cfif NOT directoryExists(baseSaveDir)>
    <cfdirectory action="create" directory="#baseSaveDir#">
</cfif>

<h2>Processing Files...</h2>
<cfoutput>

<cfloop list="#form.fileList#" index="fileName">

    <cfset folderName = trim(form["folder_" & fileName])>
    <cfset selectedTemplate = form["type_" & fileName]>
    <cfset targetFolder = baseSaveDir & folderName & "/">

    <!--- Create folder if needed --->
    <cfif NOT directoryExists(targetFolder)>
        <cfdirectory action="create" directory="#targetFolder#">
    </cfif>

    <!--- Add folder name to folderList --->
    <cfset folderList = listAppend(folderList, folderName)>

    <!--- Move uploaded PDF into folder --->
    <cffile
        action="move"
        source="#uploadDir##fileName#"
        destination="#targetFolder##fileName#">

    <!--- Determine template file --->
    <cfset useTemplateCopy = "Standard Output Template.pdf">
    <cfif selectedTemplate EQ "SINGLE">
        <cfset useTemplateCopy = "Single Output Template.pdf">
    </cfif>

    <cfset templatePath = appConfig.templatePath & useTemplateCopy> <!--- Use templatePath from config --->

    <!--- Create base PRINT.pdf --->
    <cfif fileExists(templatePath)>
        <cffile
            action="copy"
            source="#templatePath#"
            destination="#targetFolder##folderName# PRINT.pdf">
    </cfif>

    <!--- Handle multi-select locations --->
    <cfset locationFieldName = "location_" & fileName>
    <cfset selectedLocations = form[locationFieldName]>

    <!--- Ensure selectedLocations is always an array --->
    <cfif NOT isArray(selectedLocations)>
        <cfset selectedLocations = [ selectedLocations ]>
    </cfif>

    <cfset deletePrintMasterFileFlag = 0 />

    <!--- Loop through selected locations and create copies --->
    <cfloop array="#selectedLocations#" index="loc">

        <cfset suffix = "">


		<!---
		FULL BACK (FB)
		FULL FRONT (FF)
		LEFT CHEST (LC)
		RIGHT CHEST (RC)
		BACK NAPE (BN)
		RIGHT SLEEVE (RS)
		LEFT SLEEVE (LS)
		LEFT THIGH (LT)
		RIGHT THIGH (RT)
		LOWER FRONT (LF)
		LOWER BACK (LB)
		UPPER FRONT (UF)
		UPPER BACK (UB)
		LEFT WRIST (LW)
		RIGHT WRIST (RW)
		LEFT LEG (LL)
		RIGHT LEG (RL)
		NECK LABEL (NL)
		--->
        <cfif loc EQ "FULL BACK (FB)">
            <cfset suffix = "FB">
        <cfelseif loc EQ "FULL FRONT (FF)">
            <cfset suffix = "FF">
        <cfelseif loc EQ "LEFT CHEST (LC)">
            <cfset suffix = "LC">
        <cfelseif loc EQ "RIGHT CHEST (RC)">
                <cfset suffix = "RC">
        <cfelseif loc EQ "BACK NAPE (BN)">
            <cfset suffix = "BN">
        <cfelseif loc EQ "RIGHT SLEEVE (RS)">
                <cfset suffix = "RS">
        <cfelseif loc EQ "LEFT SLEEVE (LS)">
                <cfset suffix = "LS">
        <cfelseif loc EQ "LEFT THIGH (LT)">
                <cfset suffix = "LT">
        <cfelseif loc EQ "RIGHT THIGH (RT)">
            <cfset suffix = "RT">
        <cfelseif loc EQ "LOWER FRONT (LF)">
            <cfset suffix = "LF">
        <cfelseif loc EQ "LOWER BACK (LB)">
            <cfset suffix = "LB">



        <cfelseif loc EQ "No Screens">
            <cfset suffix = "RM">
        </cfif>




        <!--- Create extra copies based on suffix --->
        <cfif len(suffix)>
        	<cfif suffix is not "RM">
	            <cffile
	                action="copy"
	                source="#targetFolder##folderName# PRINT.pdf"
	                destination="#targetFolder##folderName# #suffix# PRINT.pdf">
            </cfif>
            <cfset deletePrintMasterFileFlag = 1 />
        </cfif>

        <cfscript>
            // 1. Setup paths
            exifToolPath = "/usr/local/bin/exiftool";
            sourceDir    = "#targetFolder#";

            // 2. Get the list of PDF files
            files = directoryList(sourceDir, false, "name", "*.pdf");

            for (fileName in files) {
                try {
                    // CHECK FOR "PRODUCTION"
                    // If "production" is found (case-insensitive), we skip the metadata update
                    if (findNoCase("production", fileName)) {
                        //writeOutput("<p>Skipping metadata for: #fileName# (contains 'production')</p>");
                        continue; // Moves to the next file in the loop
                    }

                    fullSourcePath = sourceDir & fileName;

                    // HANDLE MULTIPLE DOTS
                    // listLen gets the total number of parts separated by dots
                    // listDeleteAt removes only the last part (the extension)
                    totalParts = listLen(fileName, ".");
                    newTitle   = listDeleteAt(fileName, totalParts, ".");

                    //writeOutput("<h1>Processing: #newTitle#</h1>");

                    // Update XMP Title using ExifTool
                    cfexecute(
                        name      = exifToolPath,
                        arguments = "-overwrite_original -Title=""#newTitle#"" ""#fullSourcePath#""",
                        variable  = "local.stdOut",
                        errorVariable = "local.stdErr",
                        timeout   = 20
                    );
                    // Log Success Output
                    if (len(trim(local.stdOut))) {
                        writeLog(
                            file = "exiftool_results",
                            type = "Information",
                            text = "ExifTool Success: #local.stdOut#"
                        );
                    }

                    // Log Error Output
                    /*if (len(trim(local.stdErr))) {
                        writeLog(
                            file = "exiftool_results",
                            type = "Error",
                            text = "ExifTool Error: #local.stdErr#"
                        );
                    }*/
                    // Brief pause to ensure OS file handles are released
                    sleep(500);

                    // Safety check for ExifTool errors
                    if (structKeyExists(local, "stdErr") AND len(local.stdErr)) {
                        throw(message="ExifTool Error: #local.stdErr#");
                    }

                } catch (any e) {
                    writeOutput("<h3>An error occurred processing: #fileName#</h3>");
                    writeOutput("<p><strong>Message:</strong> #e.message#</p>");
                    writeOutput("<p><strong>Detail:</strong> #e.detail#</p>");
                    abort;
                }
            }

            writeOutput("Processing complete!");
        </cfscript>

    </cfloop>

    <cfif deletePrintMasterFileFlag gt 0>
	    <cffile
	        action="delete"
	        file="#targetFolder##folderName# PRINT.pdf">
    </cfif>


    <p>
        Processed <strong>#fileName#</strong> in to Folder <strong>#folderName#</strong><br />
        Template: <strong>#selectedTemplate#</strong>
    </p>

</cfloop>

</cfoutput>

<p><strong>All files processed successfully.</strong> </p>

<cfset folderList = listSort(folderList, "text", "asc") />

Here is a list of the folders you generated: [<a href="javascript:void(0)" onclick="copyToClipboard()">Copy to Clipboard</a>]<br>
<textarea rows="10" cols="50" readonly id="folderListTextarea"><cfoutput>#replaceNoCase(folderList, ",", "#chr(10)#","all")#</cfoutput></textarea>

<p>[<a href="uploadForm.cfm">Return to upload page</a>]</p>

<script>
function copyToClipboard() {
    var textarea = document.getElementById("folderListTextarea");
    textarea.select();
    document.execCommand("copy");
    alert("Folder list copied to clipboard!");
}
</script>


<cfinclude template="footer.cfm">
