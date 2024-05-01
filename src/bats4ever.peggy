{{
  function makeBits(o) {
    if(o.length <= 24 ){
        return parseInt(o.join(""), 2);
    } else {
        error("bits > 24, need to implement byte array");
    }
  }
}}

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
}


Document = children:BlockInterior {return {
    type:"Document",
    children
}}
Block
  = BlockOpen tag:(Void / Symbol) contents:BlockInterior closeCount:BlockClose? { return {
    type:"Block",
    tag,
    contents,
    closeCount
}}
BlockOpen
  = ">>" { openBlock();}
BlockClose
  = "<<" bits:Bits { closeBlock(bits+1); return bits; }
BlockInterior
  = Symbol
  / (Seq / Block / Link)*
Seq = ">" values:OpSeqBody { return {
    type:"Seq",
    values
}}
OpSeqBody = first:OptionalBits rest:("<" @OptionalBits)* { return [first, ...rest]}
Link = ">>>" ref:Symbol { return {
    type:"Link",
    ref
}}
Symbol = first:Bits rest:("<" @Bits)* {return [first,...rest]}
Bits = bits:[0-1]+ {return makeBits(bits);}
OptionalBits = Bits / Void
Void = "><" {return null;}