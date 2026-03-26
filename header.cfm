<!--- Path to config file --->
<cfset configFile = expandPath("/config/presto.conf")>

<!--- Read file contents --->
<cfset rawConfig = fileRead(configFile)>

<!--- Split into lines --->
<cfset configLines = listToArray(rawConfig, chr(10))>

<!--- Create struct to hold settings --->
<cfset appConfig = {}>

<!--- Parse each line --->
<cfloop array="#configLines#" index="line">
    <cfset line = trim(line)>

    <!--- Skip empty lines or comments --->
    <cfif line EQ "" OR left(line,1) EQ "##">
        <cfcontinue>
    </cfif>

    <!--- Split key=value --->
    <cfset key = trim(listFirst(line, "="))>
    <cfset val = trim(listRest(line, "="))>

    <!--- Store in struct --->
    <cfset appConfig[key] = val>
</cfloop>

<!--- Now you can use appConfig.outputPath, appConfig.tempPath, etc. --->

<!DOCTYPE html>
<html>
<head>
    <title><cfif isDefined("variables.title")><cfoutput>#variables.title#</cfoutput><cfelse>Presto Dashboard</cfif></title>

    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #F4F4F4;
        }

        /* Sidebar */
        .sidebar {
            width: 240px;
            height: 100vh;
            background: #1A1A1A;
            color: white;
            position: fixed;
            left: 0;
            top: 0;
            padding: 20px;
        }

        .sidebar h1 {
            font-size: 26px;
            margin-bottom: 30px;
            letter-spacing: 1px;
        }

        .nav-item {
            margin: 15px 0;
            cursor: pointer;
            font-size: 16px;
            color: white
        }

        .nav-item:hover {
            color: #D7263D;
        }

        .nav-item:visited {
            color: yellow;
        }

        /* Top bar */
        .topbar {
            margin-left: 240px;
            height: 60px;
            background: white;
            border-bottom: 1px solid #ddd;
            display: flex;
            align-items: center;
            padding: 0 20px;
            font-size: 20px;
            font-weight: bold;
        }

        /* Main content */
        .content {
            margin-left: 240px;
            padding: 20px;
        }

        .card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
    </style>
    <cfif isDefined("variables.styleIncl")>
        <link rel="stylesheet" type="text/css" href="<cfoutput>#variables.styleIncl#</cfoutput>">
    </cfif>
</head>

<body>

    <!-- Sidebar -->
    <div class="sidebar">
        <h1><a href="index.cfm">PRESTO!</a></h1>

        <div><strong>Dashboard</strong></div>
        <div class="nav-item"><a class="nav-item" href="uploadForm.cfm">Uploads</a></div>
        <div class="nav-item"><a class="nav-item" href="pipelineLookup.cfm">Pipeline Lookups</a></div>
        <!---<div class="nav-item">Jobs</div>
        <div class="nav-item">Templates</div>
        <div class="nav-item">Approvals</div>
        <div class="nav-item">Settings</div>--->
    </div>

    <!-- Top bar -->
    <div class="topbar">
        <span class="card"><cfif isDefined("variables.title")><cfoutput>#variables.title#</cfoutput><cfelse>Presto Dashboard</cfif></span>
    </div>

    <!-- Main content -->
    <div class="content">

        <div class="card">
