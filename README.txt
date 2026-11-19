PAC MEDIA - file list and quick start
=====================================

FILES IN THIS FOLDER
  index.html            The whole app (splash screen, magazine hub,
                        magazine pages, flipbook reader, admin dashboard).
                        You never need to edit this file.
  config.js             The ONLY file you edit: paste your two Supabase
                        keys here (Setup Guide, Steps 6-7).
  manifest.json         App info for the Android/iOS home-screen install.
  sw.js                 Makes the app work offline once installed.
  supabase-setup.sql    The database setup for a NEW project: paste
                        into Supabase SQL Editor (Setup Guide, Step 4).
  database-update.sql   For an EXISTING project: paste into Supabase
                        SQL Editor once (adds new branding options,
                        repairs permissions, creates the image bucket).
  PATCH-NOTES.txt       What changed in this version + how to apply it.
  assets/               (empty - logos are uploaded from the Dashboard)

HOW TO APPLY UPDATE v5 WITH THE PATCH FILE (pac-media-v5.patch)
  1. Put pac-media-v5.patch inside your project folder
     (C:\Users\User\Documents\pac).
  2. In the VS Code terminal, run these one at a time:
       git pull
       git apply pac-media-v5.patch
       git add .
       git commit -m "v5: install banner back, fullscreen flipbook"
       git push
  3. Reload the app on your phone twice (first load fetches the new
     version, the second shows it).
  4. If you have not run database-update.sql in the Supabase SQL
     Editor yet, run it once - it unlocks the logo style settings
     and locks the database to your admin account only.
  NOTE: the patch never touches config.js, so your keys stay safe.
  icons/                App icons shown on phone home screens.

QUICK START (see the Setup Guide PDF for click-by-click instructions)
  1. Unzip so the files sit directly in C:\Users\User\Documents\pac
  2. Create a free Supabase project at supabase.com
  3. Supabase > SQL Editor > New query > paste supabase-setup.sql > Run
  4. Supabase > Authentication > Sign In / Providers > Email >
     turn OFF "Confirm email" > Save
  5. Supabase > Project Settings > API: copy Project URL and anon public key
  6. Paste both keys into config.js (Notepad or VS Code), save
  7. Install Git for Windows (git-scm.com/download/win)
  8. In VS Code terminal:
       cd C:\Users\User\Documents\pac
       git init
       git add .
       git commit -m "PAC Media first version"
     then create a repo on github.com and:
       git branch -M main
       git remote add origin https://github.com/YOUR-USERNAME/pac-media.git
       git push -u origin main
  9. vercel.com > sign up with GitHub > Add New > Project > Import
     pac-media > Deploy
 10. Open https://YOUR-APP-URL/#/pac-admin and create your admin account
     (do this immediately - the setup form locks itself afterwards)
 11. Add magazines and issues in Dashboard, share the site link with
     readers and advertisers.
