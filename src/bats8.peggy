{
  let blockCounter = 0;
  function openBlock(){
      blockCounter++;
  }
  function closeBlock(closeCount){
      if(closeCount > blockCounter){
          error("closed too many blocks!");
      }
      blockCounter -= closeCount;
  }

  function fixBlockContent(block){
    if(block.closeCount === null){
      const content = block.contents;

      let i = 0;
      let hoistLevels = 0;

      //this block was actually closed by a child block
      //need to reach in and pull up any content at the wrong level
      for(;i<content.length;i++){
        const child = content[i];
        if(child.type === "Block"){
          if(child.closeCount > 0){
            //we found a child that actually closes its parent
            //need to get all siblings after this one and house
            //n levels (where n = closeCount)
            hoistLevels = child.closeCount;
            break;
          } else if(child.closeCount === null){
            const result = fixBlockContent(child);
            if(result){
              if(result.hoistLevels > 1){
                //lift one level higher
                return {
                  hoistLevels: result.hoistLevels-1,
                  hoistedContent: result.hoistedContent
                }
              } else {
                //this is it, we've got some hoisted content
                content.push(...result.hoistedContent);
              }
            }
          }
        }
      }
      if(hoistLevels > 0 && i+1 !== content.length){
        const results = {
          hoistLevels,
          hoistedContent: content.slice(i+1)
        };
        block.contents = content.slice(0,i+1);
        return results;
      }
    }
  }

  //because of the way that blocks can close their parents
  //we need to do a small cleanup pass that finds any content
  //at the wrong level
  function fixDocumentChildren(children){
    const updatedChildren = [];
    for(let child of children){
      if(child.type === "Block"){
        updatedChildren.push(child);
        const result = fixBlockContent(child);
        if(result){
          updatedChildren.push(...result.hoistedContent);
        }
      }
    }
    return updatedChildren;
  }


  function makeBits(o) {
    const bitString = o.join("").replaceAll(/[ \t\n]/g,"");
    console.log("bitstring is:" + bitString);
    if(bitString.length <= 24 ){
        return parseInt(bitString, 2);
    } else {
        error("bits > 24, need to implement byte array");
    }
  }
  function hexBits(o) {
    const hexString = o.join("").replaceAll(/[ \t\n]/g,"");
    console.log("bitstring is:" + hexString);
    if(hexString.length % 2 !== 0){
      hexString += "0";
    }
    const length = hexString.length/2;
    const bytes = new Uint8Array(length);
    for(let i=0;i<length;i++){
      bytes[i] = parseInt(hexString.substr(i*2,2),16);
    }
    return bytes;
  }
  function intBits(o) {
    const digits = o.join("").replaceAll(",","");
    if(o.length <= 10 ){
        return parseInt(digits, 10);
    } else {
        error("bits > 24, need to implement byte array");
    }
  }
  function makeString(chars){
    return chars.join("");
  }
}


Document "document"
  = _ children:BlockInterior _ {return {
      type:"Document",
      children:fixDocumentChildren(children)
  }}
Block "block"
  = BlockOpen tag:(Void / Symbol) contents:BlockInterior closeCount:BlockClose? { return {
      type:"Block",
      tag,
      contents,
      closeCount
  }}
BlockOpen "block open"
  = _ ">>" _ { openBlock();}
BlockClose "block close"
  = _ "<<" bits:Bits { closeBlock(bits+1); return bits; }
BlockInterior "block interior"
  = Symbol
  / (Seq / Block / Link)*
Seq "sequence"
  = _ ">" values:OpSeqBody { return {
      type:"Seq",
      values
  }}
OpSeqBody = _ first:OptionalBits _ rest:("<" _ @OptionalBits _)* { return [first, ...rest]}
Link "link"
  = _ ">>>" ref:Symbol { return {
      type:"Link",
      ref
  }}
Symbol "symbol"
  = _ first:Bits _ rest:("<" _ @Bits _ )* {return [first,...rest]}
Bits
  = BitsLiteral
  / HexLiteral
  / Integer
  / String

BitsLiteral = "0b" bits:[0-1 \t\n]+ {return makeBits(bits);}
HexLiteral = "0x" hex:[0-9a-f \t\n]+ {return hexBits(hex);}
Integer = digits:[0-9,]+ {return intBits(digits);}
String = "\"" chars:("\\"["'tnrf\\] / [^"])* "\"" { return makeString(chars); }
OptionalBits = Bits / Void
Void = "><" {return null;}
_
  = [ \t\n]*