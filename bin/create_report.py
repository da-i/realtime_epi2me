#!/usr/bin/env python

import glob
import os


def create_table(folder_path = ".", extension= ".txt"):
    """Create a table for all files ending in the given extension."""
    # Ensure the extension starts with a dot
    if not extension.startswith('.'):
        extension = '.' + extension
    table = """
<table>
<tr>
    <th>File</th>
    <th>Content summary</th>
</tr>
"""
    # Add star to obtain all files.
    search_pattern = os.path.join(folder_path, f'*{extension}')
    files = glob.glob(search_pattern)
    for file in files:
        filename = file
        file_content_summary = open(file, "r").readlines()
        file_content_summary = [x.strip() for x in file_content_summary]
        for i,x in  enumerate(file_content_summary):
            table += f"<tr><td>{filename}</td><td>{x}</td></tr>"
    table += "</table>"
    return table


def create_report():
    with open("report.html", "w") as f:
        f.write(report_start)
        f.write(create_table())
        f.write(report_tail)



if __name__ == '__main__':
    report_start = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Boilerplate HTML Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
    </style>
</head>
<body>
    <p>This is a sample paragraph.</p>

"""

    report_tail = """
    <p id="countdown"></p>

        <script>
            let countdown = 5;
            const countdownElement = document.getElementById('countdown');

            function updateCountdown() {
                countdownElement.textContent = 'Reloading in ' + countdown + ' seconds...';
                countdown--;
                if (countdown < 0) {
                    location.reload();
                }
            }

            setInterval(updateCountdown, 1000);
            updateCountdown();
        </script>
    </body>
    </html>
    """
    create_report()
