 <cfset variables.title = "Process PDF Files">
 <cfset variables.styleIncl = "assets/css/processUploads.css">
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

<h2>Assign Folders &amp; Types for Each PDF</h2>
<cfoutput>
<form action="finalizeFolders.cfm" method="post">
    <cfset variables.counter = 1 />
    <cfloop array="#uploadResults#" index="fileInfo">
        <cfset savedName = fileInfo.serverFile>
        <cfset fileUrl = uploadUrl & savedName>

        <div style="margin-bottom:25px; padding:10px; border:1px solid ##ccc;">

            <!--- PDF Preview Link --->
            <strong>(#variables.counter#) Uploaded File:</strong>
            <!--- KEEP FOR NOW
            <a href="##"
            onclick="highlightLink(this); window.open('#fileUrl#', 'newwindow', 'width=1200, height=650'); return false;">
                #savedName#
            </a>
            --->


            <div id="pdf-preview-box"><iframe id="preview-frame" width="100%" height="100%" frameborder="0"></iframe></div>

            <!-- Your ColdFusion Links -->
            <a href="#fileUrl#"
               onmouseenter="anchorPreview(this, '#fileUrl#')"
               onmouseleave="clearPreview(this)">
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
            <select name="location_#savedName#[]" multiple size="7" style="width:250px;">
                <option value="No Location Specified" selected>No Location Specified</option>
                <option value="No Screens">No Screens / Applique Only</option>
                <option value="FULL FRONT (FF)">FULL FRONT (FF)</option>
                <option value="FULL BACK (FB)">FULL BACK (FB)</option>
                <option value="LEFT CHEST (LC)">LEFT CHEST (LC)</option>
                <option value="RIGHT CHEST (RC)">RIGHT CHEST (RC)</option>
                <option value="LOWER FRONT (LF)">LOWER FRONT (LF)</option>
                <option value="LOWER BACK (LB)">LOWER BACK (LB)</option>
                <option value="UPPER FRONT (UF)">UPPER FRONT (UF)</option>
                <option value="UPPER BACK (UB)">UPPER BACK (UB)</option>
                <option value="LEFT SLEEVE (LS)">LEFT SLEEVE (LS)</option>
                <option value="RIGHT SLEEVE (RS)">RIGHT SLEEVE (RS)</option>
                <option value="LEFT WRIST (LW)">LEFT WRIST (LW)</option>
                <option value="RIGHT WRIST (RW)">RIGHT WRIST (RW)</option>
                <option value="LEFT LEG (LL)">LEFT LEG (LL)</option>
                <option value="RIGHT LEG (RL)">RIGHT LEG (RL)</option>
                <option value="LEFT THIGH (LT)">LEFT THIGH (LT)</option>
                <option value="RIGHT THIGH (RT)">RIGHT THIGH (RT)</option>
                <option value="BACK NAPE (BN)">BACK NAPE (BN)</option>
                <option value="NECK LABEL (NL)">NECK LABEL (NL)</option>
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
        <cfset variables.counter = variables.counter + 1 />
    </cfloop>
	<br><br>
	<p style="text-align:center;">
        <input type="submit" value="Create Folders &amp; Move Files">
    </p>
    <br><br>
</form>
</cfoutput>

<cfinclude template="footer.cfm">

<script>
  function xhighlightLink(el) {

    // 1. Remove the highlight from any link that currently has it
    document.querySelectorAll('.preview-active').forEach(link => {
      link.classList.remove('preview-active');
    });
    // 2. Add the highlight to the clicked link
    el.classList.add('preview-active');
  }



  const box = document.getElementById('pdf-preview-box');
  const frame = document.getElementById('preview-frame');

  function anchorPreview(el, url) {
    // 1. Highlight the link
    el.style.backgroundColor = 'yellow';

    // 2. Get the link's position relative to the viewport
    const rect = el.getBoundingClientRect();

    // 3. Calculate position (Relative to the Page Scroll)
    const scrollLeft = window.pageXOffset || document.documentElement.scrollLeft;
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

    // 4. Place box to the RIGHT of the link with 15px gap
    box.style.left = (rect.right + scrollLeft + 15) + 'px';
    box.style.top = (rect.top + scrollTop) + 'px';

    // 5. Show and Load
    box.style.display = 'block';
    if (frame.src !== url) frame.src = url;
  }

  function clearPreview(el) {
    el.style.backgroundColor = 'transparent';
    box.style.display = 'none';
  }
</script>
