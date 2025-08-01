 # import SFTP module for powershell
        Import-Module Posh-SSH

        # assisgn variables for sftp server and credentials 
        $SftpServer = "use1.sftp.shrd.staging.zsservices.com"
        $password = "/rmJvGaG5PW6Y+YwdGHhaPE7lyRPfP5S/dLMkyi6" | ConvertTo-SecureString -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ('AKIAQWWF3ZY2PSQCFQS6', $password)
        $localdir = "C:\CVS_SFTP\CVS"
        $sftpSourcePath = "/aws-a0100-use1-00-d-s3b-mvns-poc-data01/Infucare/"
        $lastDownloadTimestamp = Get-Content "C:\CVS_SFTP\CVS_Backup\LastDownloadTimestamp.txt" | Out-String -ErrorAction SilentlyContinue

        # establish new SFTP sessin
        $sftpSession = New-SFTPSession -ComputerName $SftpServer -Credential $cred -AcceptKey -Port 22 -Force
                
        # Get all items from the SFTP source folder
        $sftpFiles = Get-SFTPChildItem -SessionId $sftpSession.SessionId -Path $sftpSourcePath

        # Filter for new files (or files modified after the last download)
        if ($lastDownloadTimestamp) {
            $newFiles = $sftpFiles | Where-Object { $_.LastWriteTime -gt $lastDownloadTimestamp }
        } else {
            # If no previous timestamp, consider all files as "new" for the first run
            $newFiles = $sftpFiles
        }

        # Copy the new files
        foreach ($file in $newFiles) {
            Write-Host "Copying $($file.Name)..."
            Get-SFTPItem -SessionId $sftpSession.SessionId -Path $file.FullName -Destination $localdir -Force
        }

        # Update the last successful download timestamp
        Set-Content "C:\CVS_SFTP\CVS_Backup\LastDownloadTimestamp.txt" (Get-Date).ToString()
        

        # Close the SFTP session when done
        Remove-SFTPSession -SessionId $SessionID