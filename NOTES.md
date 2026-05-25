### OVERVIEW

This file should contain all of the things that I did, that I didn't do, and that I would've done given more time. This is my first time setting up a Django app, and as a result I used Gemini (free version with the Flash model) to analyze the code and set up Docker and systemd, all transcripts are included in the "transcripts" folder.

I've also updated the README.md file to reflect the changes made to mise.toml.

I mainly focused on two areas - improving performance on key endpoints and also making it easier to run the application locally. I also included a Docker file and a systemd service template, however I don't think this is enough to have the full CI pipeline (we still need to pull changes from the repo for the app, manage releases, tests, handle journalctl logs, etc.).

As a personal note, I really enjoyed working through this small project (it took me around 5 hours in total) as this is my first, albeit basic, exposure to Django, and working through issues related to performance, concurrency and code safety is something I enjoy thoroughly.

### THINGS I DID:

## DATABASE:

- Added an index to both blog_post and blog_comment's "created_at" column.

## POSTS:

- Updated the list_posts endpoint with pagination and proper joins for the author and tag entities for performance purposes, the original endpoint fetched every single post and, additionally, joined both authors and tags when serializing the response. I left the page size number as a static value to reduce logic (otherwise we'd need to validate user input).

- Updated the search_posts endpoint with pagination, same reasoning as above.

- Updated the posts_by_tag endpoint with pagination, same reasoning as above.

- Removed the serialization function and instead opted to use ".only()" calls to avoid the serialization running before proper pagination can take place.

- Updated the get_post endpoint so the view count is directly updated in the database to avoid a race condition where the view_count value isn't updated properly if two people view the same post at the same time, this of course still means an incorrect view_count value could be returned to the client, but I believe it's a valid trade-off (locking the row with a transaction would be too costly for this particular endpoint, IMO).

## APP USAGE AND DEPLOYMENT:

- Regarding the dev environment, I simplified the initial setup of the app for local development by combining all commands into one mise task - might not be necessarily the smartest thing to do, but it keeps things simpler for me (i.e all I have to do is use one commnad to run the app), this of course doesn't take into account setting up a local PostgreSQL database and whatnot.

- For prod, I decided to go with docker and systemd to keep things simple, but despite that it's what took most of my time (particularly setting up and testing Dockerfile) due to my lack of experience with Docker and also setting up a Django app properly. NOTE: I included the database seeding in the Docker migration phase for simplicity sake, but this obviously should not be in production.

- Changed mise.toml with new tasks to facilitate app usage in dev environments.

### THINGS I DIDN'T DO:

- Use cursors or a more complex pagination system, given the scope of this project I don't think it's necessary to go overboard, explaining why I took the simple approach of an static page_size value.

- Secure the user endpoints - being able to get random users by ID, fetching them by email or passing author_id in the body for post/comment creation is extremely unsafe for any production app, but given that isn't in the main 3 goals for this project, I've opted to ignore that particular aspect.

- Add proper error handling (like a dictionary and a more structured response), no point given the scope of the app (although highly necessary in any app, in my opinion).

- Dev comments (not really needed for this? I'm not entirely sure).

### THINGS I'D DO IF I HAD MORE TIME:

- While tags cannot be created in the baseline project, there is no unique key constraint for the slug column and tags should have it, however they're technically not required given that they cannot be created by user input (only through manual database insertion).

- The create_post and create_comment endpoints have poor security given that the author_id is obtained directly from the request's payload, but fixing this would require a proper authentication system in place.

- Regarding authentication, I'd probably use a simple JWT passed to our backend as a header (it really depends on how complex the overall system would be - do we really need to track sessions and validate JWTs for a blog?).

- Find a safer way to use the ".only()" function, as it is not immediately obvious for developers with no prior experience in this app or Django (like me) that the selected fields must also coincide with the response schema, although I think it's a minor issue and can be quickly caught in development (not something that should break an app in production with proper QA...)

- Perform proper stress testing of endpoints - the endpoints, after being fixed, are faster, but obviously this should be stress tested with actual load instead of me being the only one using them.

- Have an actual CI pipeline for GitHub so the Docker + systemd usage makes a little bit more sense - this would be required to properly deploy new changes to a host machine and to then update the docker container with the new changes.

- Have a proper bash script that setups the app instead of relying on mise.toml too much (for example, if the database creation process fails because the databse already exists, then continue with the setup).




