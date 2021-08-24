# Haskell + TypeScript

This is a simple example for me to base future
projects on which use Haskell + TypeScript. It
provides scaffolding for dealing with cors
requests when using the `yarn start` command,
and has a convenient installation script which
can be expanded upon to move other artifacts of
importance or create file structure which is
important to your particular application. This
does _not_ contain a production grade server
with middlewares you'd want to run in production.
The choices you'll make in constructing that will
probably be specific to the stack you've chosen:
tracing, logging, metrics, etc.

The only opinionated choices I've made on the
TypeScript side is including `styled-components`.
I'm just going to want to use this every time, so
it makes sense for me to add it into the template.

I'm generating the TypeScript types with
`aeson-typescript`, but I am not generating
a client. There are a couple options here:
write my own machinery to generate requests using
fetch or something, or use OpenAPI to generate
the typescript instead of using `aeson-typescript`.
Both routes should be explored, but the dependencies
for the OpenAPI client generator were pretty immense
last I checked.
