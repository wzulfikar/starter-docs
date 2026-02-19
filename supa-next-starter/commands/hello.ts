import { z } from "zod";
import { parser } from "zod-opts";

main();

/**
Example:
bun commands/hello.ts --name John
*/
async function main() {
  const params = parser()
    .options({
      name: { type: z.string() },
    })
    .parse();
  console.log(`Hello, ${params.name}!`);
}
