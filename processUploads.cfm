<cfinclude template="header.cfm">

<cfset uploadDir = expandPath("./tempUploads/")>
<cfset uploadUrl = "./tempUploads/"> <!--- For href links --->

<!--- Ensure temp upload directory exists --->
<cfif NOT directoryExists(uploadDir)>
    <cfdirectory action="create" directory="#uploadDir#">
</cfif>

<!--- Handle file uploads --->
<cffile
    action="uploadAll"
    destination="#uploadDir#"
    nameConflict="overwrite"
    result="uploadResults">

<h2>Assign Folders & Types for Each PDF</h2>
<cfoutput>
<form action="finalizeFolders.cfm" method="post">

    <cfloop array="#uploadResults#" index="fileInfo">
        <cfset savedName = fileInfo.serverFile>
        <cfset fileUrl = uploadUrl & savedName>

        <div style="margin-bottom:25px; padding:10px; border:1px solid ##ccc;">

            <!--- PDF Preview Link --->
            <strong>Uploaded File:</strong>
            <a href="##" onclick="window.open('#fileUrl#', 'newwindow', 'width=800, height=350'); return false;">
                #savedName#
            </a>
            <br><br>

            <!--- Folder Name Input --->
            Folder Name:
            <cfif findNoCase(".pdf", savedName) GT 0>
                <cfset useFolderName = replace(savedName, ".pdf", "", "all")>
            </cfif>
            <cfif findNoCase("PRODUCTION", useFolderName) GT 0>
                <cfset useFolderName = replace(useFolderName, "PRODUCTION", "", "all")>
            </cfif>
            <input type="text" name="folder_#savedName#"
                   value="#trim(useFolderName)#"
                   style="width:250px;">
            <br><br>

            <!--- NEW: Multi-select Location Dropdown --->
            <label><strong>Location(s):</strong></label><br>
            <select name="location_#savedName#[]" multiple size="3" style="width:250px;" size>
                <option value="No Location Specified" selected>No Location Specified</option>
                <option value="No Screens">No Screens / Applique Only</option>
                <option value="FULL BACK (FB)">FULL BACK (FB)</option>
                <option value="FULL FRONT (FF)">FULL FRONT (FF)</option>
                <option value="LEFT CHEST (LC)">LEFT CHEST (LC)</option>
                <option value="BACK NAPE (BN)">BACK NAPE (BN)</option>
            </select>
            <br><br>

            <!--- Radio Buttons for STANDARD / SINGLE --->
            <div style="margin-left:20px;">
                <label>
                    <input type="radio" name="type_#savedName#" value="STANDARD" checked>
                    STANDARD
                </label>
                <br>
                <label>
                    <input type="radio" name="type_#savedName#" value="SINGLE">
                    SINGLE
                </label>
            </div>

            <!--- Hidden field to track filenames --->
            <input type="hidden" name="fileList" value="#savedName#">

        </div>
    </cfloop>
	<br><br>
    <input type="submit" value="Create Folders &amp; Move Files">
	<br><br>
</form>
</cfoutput>

<cfinclude template="footer.cfm">
