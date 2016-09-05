import "dapple/test.sol";
import "dapple/reporter.sol";


contract Trie {

  struct Node {
    bool known;
    byte letter;
    byte[] childset; // only needed for iteration
    mapping (byte => bool) child;
  }

  mapping (bytes => Node) node;

  function Trie() {
  }

  function add(bytes word) {
    bytes memory current;
    for (uint8 i; i<word.length; i++) {
      current = __slice(word, 0, i);
      //@log `bytes current`
      if(!node[current].child[word[i]]) {
        node[current].child[word[i]] = true;
        node[current].childset[node[current].childset.length++] = word[i];
      }
    }
  }

  function isInside(bytes word) returns (bool success) {
    bytes memory current;
    for (uint8 i; i<word.length; i++) {
      current = __slice(word, 0, i);
      //@log `bytes current`
      if(!node[current].child[word[i]]) {
        return false;
      }
    }
    return true;
  }

  // accessors
  function getChildrenLength(bytes _nodeId) constant returns (uint length) {
    return node[_nodeId].childset.length;
  }
  function getChildAtIndex(bytes _nodeId, uint i) constant returns (byte letter) {
    return node[_nodeId].childset[i];
  }

  // helper
  function __slice(bytes _in, uint8 from, uint8 to) internal returns(bytes out) {
    out = new bytes(to-from);
    for(var i=0; i< to-from; i++) {
      out[i] = _in[from+i];
    }
    return out;
  }
}

contract TrieTest is Test, Reporter {
  Trie trie;
  function setUp() {
    trie = new Trie();
    setupReporter('./report.md');
  }

  function testAddAndVerify() {
    trie.add("foo");
    assertTrue(trie.isInside("foo"));
  }

  function testFailWrongLookup() {
    trie.add("foo");
    assertTrue(trie.isInside("bar"));
  }

  function testFormat() {
    trie.add("foo");
    trie.add("foa");
    trie.add("foamous");
    trie.add("bar");
    //@doc ## Tree
    //@doc here the rendered tree:
    format();
  }

  function format() wrapCode("viz") {
    //@doc digraph {
    formatTree("");
    //@doc }
  }

  function formatTree(bytes current) internal {
    //@doc "`bytes current`" [label="`string string(current)`"];
    for (uint i; i<trie.getChildrenLength(current); i++) {
      byte next = trie.getChildAtIndex(current,i);
      bytes memory child = __concatOne(current,next);
      bytes memory _next = new bytes(1); // only needed for string convertion
      _next[0] = next;
      
      //@doc "`bytes current`" -> "`bytes child`" [label="`string string(_next)`"];
      formatTree(child);
    }
  }

  // helper
   function __concatOne(bytes memory a, byte b) internal returns(bytes memory c) {
    c = new bytes(a.length+1);
    for (uint8 i = 0; i<a.length; i++) {
      c[i] = a[i];
    }
    c[a.length] = b;
    return c;
  }


}
