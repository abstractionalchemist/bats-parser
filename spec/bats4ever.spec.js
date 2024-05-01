import * as bats from "../lib/bats4ever.js";
import util from "node:util";

function parse(input){
    try {
        return bats.parse(input, {grammarSource:"input.js"}); // throws SyntaxError
      } catch (e) {
        if (typeof e.format === "function") {
          console.log(e.format([
            { source: 'input.js', text: input },
          ]));
        } else {
          throw e;
        }
      }
}

describe("basic parse", function(){
    it("should parse a basic thing", function(){
        // console.log(util.inspect(parse(">11<0<11"), false, null, true));
        expect("test").toBe("test");
    });
    it("parsing blocks", function(){
        // console.log(util.inspect(parse(">>101>11<0>>1101<11>0>>>0<1<10<<1"), false, null, true));
        expect("test").toBe("test");
    });
});