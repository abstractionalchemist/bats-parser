import * as bats from "../lib/bats8.js";
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
  // it("should parse a basic thing", function(){
  //     // console.log(util.inspect(parse(">0b11<0<11"), false, null, true));
  //     expect("test").toBe("test");
  // });
  // it("parsing blocks", function(){
  //     // console.log(util.inspect(parse(">>101>11<0>>1101<11>\"hello\">>>0<1<10<<1"), false, null, true));
  //     expect("test").toBe("test");
  // });
  // it("parsing multiline", function(){
  //   const batTxt = `
  //     >"hello"<"
  //       wor\nld 
  //       multiline!"
  //     >>"some tag"
  //       >123,456
  //       >456<7<8<9
  //       >>"nested"
  //         >0b 10010101 10011001
  //         >0x a0 b1 aa ff 00
  //       <<1
  //     >>>123<45
  //     >>><"empty tag"<<0
  //   `
  //   console.log(util.inspect(parse(batTxt), false, null, true));
  //   expect("test").toBe("test");
  // });
  it("parsing block closing", function(){
    const batTxt = `
      >>"first"
        >>"second">>"third">"innermost"<<1
        >>"hoisted"<<1
      >"top last"
    `
    console.log(util.inspect(parse(batTxt), false, null, true));
    expect("test").toBe("test");
  });
});