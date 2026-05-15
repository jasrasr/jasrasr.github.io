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
- 1.6  Added navigation for current repo pages and apps
*/

$revision = "1.6.0";
$fileName = basename(__FILE__);
$year = date("Y");

$navSections = [
    "Main Pages" => [
        ["href" => "/calculate-days.html", "label" => "Calculate Days"],
        ["href" => "/chuck.html", "label" => "Chuck Norris"],
        ["href" => "/generate-password.html", "label" => "Generate Password"],
        ["href" => "/links.html", "label" => "Links"],
        ["href" => "/login.html", "label" => "Login"],
        ["href" => "/menu.html", "label" => "Menu"],
        ["href" => "/prize-wheel.html", "label" => "Prize Wheel"],
        ["href" => "/screensize.html", "label" => "Screen Size"],
        ["href" => "/spin-wheel.html", "label" => "Spin Wheel"],
    ],
    "Apps" => [
        ["href" => "/me/", "label" => "Me"],
        ["href" => "/social-links/", "label" => "Social Links"],
        ["href" => "/updates/", "label" => "Updates"],
    ],
    "Time Clock" => [
        ["href" => "/time-clock/", "label" => "Time Clock"],
        ["href" => "/time-clock/admin.html", "label" => "Admin"],
        ["href" => "/time-clock/index-hostinger.html", "label" => "Hostinger Clock"],
        ["href" => "/time-clock/admin-hostinger.html", "label" => "Hostinger Admin"],
    ],
];

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
    <title>Repo Navigation</title>
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
            grid-template-rows: auto 1fr auto;
            background: #f6f7fb;
            color: #1f2933;
        }

        header {
            padding: 24px;
            background: #111827;
            color: #fff;
        }

        header h1 {
            font-size: clamp(2rem, 6vw, 4rem);
            line-height: 1;
        }

        header p {
            margin-top: 8px;
            color: #d1d5db;
            font-size: 1rem;
        }

        main {
            width: min(1120px, 100%);
            margin: 0 auto;
            padding: 24px;
        }

        .nav-section + .nav-section {
            margin-top: 28px;
        }

        .nav-section h2 {
            margin-bottom: 12px;
            font-size: 1.1rem;
            color: #4b5563;
            text-transform: uppercase;
            letter-spacing: 0.08em;
        }

        .links {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
            gap: 12px;
        }

        .link-area {
            min-height: 96px;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 18px;
            border-radius: 8px;
            text-decoration: none;
            color: white;
            font-size: 1.25rem;
            font-weight: 600;
            text-align: center;
            transition: transform 0.1s ease, box-shadow 0.1s ease, opacity 0.1s ease;
            box-shadow: 0 10px 22px rgba(15, 23, 42, 0.12);
        }

        .link-area:hover,
        .link-area:focus {
            transform: translateY(-2px);
            box-shadow: 0 14px 28px rgba(15, 23, 42, 0.18);
            outline: none;
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
            header,
            main {
                padding: 18px;
            }

            .link-area {
                min-height: 82px;
                font-size: 1.05rem;
            }
        }
    </style>
</head>

<body>

    <header>
        <h1>Repo Navigation</h1>
        <p>Quick links to the pages and apps in this repository.</p>
    </header>

    <main>
        <?php foreach ($navSections as $sectionName => $links) : ?>
            <section class="nav-section" aria-labelledby="<?php echo strtolower(str_replace(' ', '-', $sectionName)); ?>">
                <h2 id="<?php echo strtolower(str_replace(' ', '-', $sectionName)); ?>"><?php echo htmlspecialchars($sectionName); ?></h2>
                <div class="links">
                    <?php foreach ($links as $link) : ?>
                        <a href="<?php echo htmlspecialchars($link["href"]); ?>" class="link-area"><?php echo htmlspecialchars($link["label"]); ?></a>
                    <?php endforeach; ?>
                </div>
            </section>
        <?php endforeach; ?>
    </main>

    <footer>
        <?php echo "$fileName | Rev $revision | © $year | Modified $modified"; ?>
    </footer>

</body>
</html>
