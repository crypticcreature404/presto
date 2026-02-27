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

    <!--- Loop through selected locations and create copies --->
    <cfloop array="#selectedLocations#" index="loc">

        <cfset suffix = "">

        <cfif loc EQ "FULL BACK (FB)">
            <cfset suffix = "FB">
        <cfelseif loc EQ "FULL FRONT (FF)">
            <cfset suffix = "FF">
        <cfelseif loc EQ "LEFT CHEST (LC)">
            <cfset suffix = "LC">
            <cfelseif loc EQ "LEFT CHEST (LC)">
        <cfelseif loc EQ "BACK NAPE (BN)">
            <cfset suffix = "BN">
         <cfelseif loc EQ "RIGHT CHEST (RC)">
                <cfset suffix = "RC">
        <cfelseif loc EQ "RIGHT SLEEVE (RS)">
                <cfset suffix = "RS">
        <cfelseif loc EQ "LEFT SLEEVE (LS)">
                <cfset suffix = "LS">
        <cfelseif loc EQ "LEFT THIGH (LT)">
                <cfset suffix = "LT">
        <cfelseif loc EQ "RIGHT THIGH (RT)">
            <cfset suffix = "RT">
        <cfelseif loc EQ "No Screens">
            <cfset suffix = "RM">
        </cfif>




        <!--- Only create extra copies for FB or FF --->
        <cfif len(suffix)>
            <cffile
                action="copy"
                source="#targetFolder##folderName# PRINT.pdf"
                destination="#targetFolder##folderName# #suffix# PRINT.pdf">
        </cfif>

    </cfloop>

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
