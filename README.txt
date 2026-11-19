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
  supabase-setup.sql    The database setup: paste into Supabase SQL Editor
                        (Setup Guide, Step 4).
  assets/pac-logo.png   The white PAC logo shown on the red splash screen.
                        Replace this file with your real logo (same name),
                        or upload a logo later from the Dashboard > Branding.
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
