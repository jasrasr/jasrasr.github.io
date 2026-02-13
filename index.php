<?php
/*
File Name   : links.php
Author      : Jason Lamb (with help from ChatGPT)
Created     : 2026-02-01
Modified    : Auto (via filemtime when supported)
Revision    : 1.5.0

Change Log:
- 1.0  Initial mobile full-screen layout
- 1.1  Added footer + revision display
- 1.2  Switched to scalable grid
- 1.3  Added color cycling support
- 1.4  Prepared for PHP migration
- 1.5  Added true file modification date using filemtime()
*/

$revision = "1.5.0";
$fileName = basename(__FILE__);
$year = date("Y");

if (function_exists("filemtime")) {
    $modified = date("m/d/Y", filemtime(__FILE__));
} else {
    $modified = "Static Host";
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Links</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }

        body {
            min-height: 100vh;
            display: grid;
            grid-template-rows: 1fr auto;
        }

        /* ===== Link Grid ===== */
        .links {
            display: grid;
            grid-template-columns: 1fr;
            grid-auto-rows: minmax(120px, 1fr);
        }

        .link-area {
            display: flex;
            justify-content: center;
            align-items: center;
            text-decoration: none;
            color: white;
            font-size: 2rem;
            font-weight: 600;
            text-align: center;
            transition: transform 0.1s ease, opacity 0.1s ease;
        }

        .link-area:active {
            transform: scale(0.98);
            opacity: 0.9;
        }

        /* Color cycling */
        .link-area:nth-child(6n+1) { background-color: #007BFF; }
        .link-area:nth-child(6n+2) { background-color: #28A745; }
        .link-area:nth-child(6n+3) { background-color: #FFC107; color: #222; }
        .link-area:nth-child(6n+4) { background-color: #DC3545; }
        .link-area:nth-child(6n+5) { background-color: #6F42C1; }
        .link-area:nth-child(6n+6) { background-color: #20C997; }

        footer {
            text-align: center;
            padding: 8px;
            font-size: 0.85rem;
            color: #666;
            background: #f4f4f4;
            border-top: 1px solid #ddd;
        }

        @media (max-width: 600px) {
            .link-area {
                font-size: 1.6rem;
            }
        }
    </style>
</head>

<body>

    <div class="links">
        <a href="/mpg/" class="link-area">MPG</a>
        <a href="/cvc/" class="link-area">CVC</a>
        <a href="/box/" class="link-area">BOX</a>
        <a href="/updates/" class="link-area">UPDATES</a>
    </div>

    <footer>
        <?php echo "$fileName | Rev $revision | © $year | Modified $modified"; ?>
    </footer>

</body>
</html>
