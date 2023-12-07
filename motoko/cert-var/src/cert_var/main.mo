/// Simple counter (see `Counter.mo`), but uses `mo:base/CertifiedData` to
/// implement the counter value as a certified variable.
import CD "mo:base/CertifiedData";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Text "mo:base/Text";

actor Variable {

  var value : Nat32 = 0;


  /// Helper; should be in base?
  /// LE encoding matches Candid encoding of Nat32, for consistency and convenience.
  func blobOfNat32(n : Nat32) : Blob {
    let byteMask : Nat32 = 0xff;
    func byte(x : Nat32) : Nat8 {
      Nat8.fromNat(Nat32.toNat(x))
    };
    Blob.fromArray(
      [byte(((byteMask << 0 ) & value) >> 0),
       byte(((byteMask << 8 ) & value) >> 8),
       byte(((byteMask << 16) & value) >> 16),
       byte(((byteMask << 24) & value) >> 24)])
  };

  /// Update counter and certificate (via system).
  public func inc() : async Nat32 {
    value += 1;
    CD.set(blobOfNat32(value));
    return value;
  };

  public func set(newValue : Nat32) : async () {
    value := newValue;
    CD.set(blobOfNat32(value));
  };

  /// Returns the current counter value,
  /// and, if available, an unforgeable certificate (from the system) about its authenticity.
  /// When called via update call or inter-canister call, no certificate is present (and not needed,
  /// as in these cases the system already certifies the response)
  public query func get() : async { value : Nat32; certificate : ?Blob } {
// '0x0000000000000000000000000000000000012'
      return { value; certificate = CD.getCertificate() }
  };
}


// import CD "mo:base/CertifiedData";
// import Blob "mo:base/Blob";
// import Nat8 "mo:base/Nat8";
// import Nat32 "mo:base/Nat32";
// import Text "mo:base/Text";

// actor Variable {

//   var value : Text = "0"; // Change the type to Text for storing strings

//   /// Helper; should be in base?
//   /// LE encoding matches Candid encoding of Text (UTF-8), for consistency and convenience.
//   func blobOfText(t : Text) : Blob {
//     let utf8Bytes = Text.encodeUtf8(t);
//     Blob.fromArray(Array.map(Nat8.fromNat, utf8Bytes))
//   };

//   /// Update counter and certificate (via system).
//   public func inc() : async Text {
//     // Incrementing a string might not make sense, so this is just a placeholder
//     // Adjust this logic based on your requirements
//     value := Nat32.toText(Nat32.fromText(value) + 1);
//     CD.set(blobOfText(value));
//     return value;
//   };

//   public func set(newValue : Text) : async () {
//     value := newValue;
//     CD.set(blobOfText(value));
//   };

//   /// Returns the current counter value,
//   /// and, if available, an unforgeable certificate (from the system) about its authenticity.
//   /// When called via update call or inter-canister call, no certificate is present (and not needed,
//   /// as in these cases the system already certifies the response)
//   public query func get() : async { value : Text; certificate : ?Blob } {
//     return { value; certificate = CD.getCertificate() };
//   };
// };
