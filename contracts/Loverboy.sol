//         .                                                                                 
//                                                          ..                                        
//                                                                                                    
//                                                                                                    
//                     .                                                                              
//                :^!~.         .^!~.                     .:~~.                                       
//               .!YBP^          ~PG?^                     ~G#Y~.                                     
//                ~?PY.  ^JP555YJ5#@&BP55555J7.            :?P#G!.                                    
//           .!J5GGB&#G5?7??7J5B@&J77??777??7~.      :7J?!.  ~G#P?:                                   
//           .^!!?PB#G?~^:   ^5GJ~    ^!?!.          ^5BGJ:  .!YBP^  :?J!^.                           
//               :5#BY.    .7YY7.   .!B&P?:      ^YY^^5BGJ:    .^^.  :YBB5:                           
//        ..     !B@BPP?. ^J#&BGGGBB##&P~      .!5&G^:5BPJ:           :?#&?^.                         
//             .7YPB##&B5YPGG5J?7Y&@@G!:.~55~  ^YGPJ.:5BPJ:            :YB#P^                         
//            .!GB5YGP77P5^  .^?B@&G!. :JB&G^  !#&Y~ :5BPJ:             .!#&J~.                       
//           :7YJ?7?P5^    .!Y#@#Y^  :JP#G!. .~J&B~  ^5GGJ:          ^GG!^J5Y7:                       
//           :??^:!JG5: .~JG&#57.  ^JG&G!.   :7Y5?:  ^5BPJ:         .!##7:                            
//          ..   .~JG5:.!YPY^  .:7P##&#P7:.          ^5GGJ:        .^J&B^  .                          
//      ..       .~JG5^     .^!JGB57::75BG?^.        :?5GP7~~^^^^^^!YGPJ:                             
//              .!JG5^  :!YGBG57^     .~JBBJ~.        :?PGBBBBBBBBBP?:                               
//               .^7J?:  ~Y5?^           .~77!.                             
//
//
//
//                ooo        ooooo           oooo                           
//                `88.       .888'           `888                           
//                 888b     d'888   .oooo.    888  oooo   .ooooo.  oooo d8b 
//                 8 Y88. .P  888  `P  )88b   888 .8P'   d88' `88b `888""8P 
//                 8  `888'   888   .oP"888   888888.    888ooo888  888     
//                 8    Y     888  d8(  888   888 `88b.  888    .o  888     
//                o8o        o888o `Y888""8o o888o o888o `Y8bod8P' d888b    
//                                                          
//                                                          
//                                    Creadted By Orbs                             
//                            
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import 'erc721a/contracts/ERC721A.sol';
import 'erc721a/contracts/IERC721A.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Strings.sol';


contract Loverboy is ERC721A, Ownable, ReentrancyGuard {

  using Strings for uint256;

  mapping(address => bool) public whitelistClaimed;
  mapping(address => bool) public remilialistClaimed;
  mapping(address => bool) public whitelistedAddresses;
  mapping(address => bool) public remilialistedAddresses;


  string public uriPrefix = 'ipfs:///';
  string public uriSuffix = '.json';
  string public hiddenMetadataUri;
  
  uint256 public cost;
  uint256 public whitelistCost;
  uint256 public remiliaCost;
  uint256 public maxSupply;
  uint256 public maxMintAmountPerTxPublic;
  uint256 public maxMintAmountPerTxRemilia;
  uint256 public maxMintAmountPerTxWhitelist;

  bool public paused = true;
  bool public whitelistMintEnabled = false;
  bool public remiliaSaleEnabled = false;
  bool public revealed = true;

  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    uint256 _cost,
    uint256 _whitelistCost,
    uint256 _remiliaCost,
    uint256 _maxSupply,
    uint256 _maxMintAmountPerTxPublic,
    uint256 _maxMintAmountPerTxRemilia,
    uint256 _maxMintAmountPerTxWhitelist,
    string memory _hiddenMetadataUri
  ) ERC721A(_tokenName, _tokenSymbol) {
    setCost(_cost);
    setWhitelistCost(_whitelistCost);
    setRemiliaCost(_remiliaCost);
    maxSupply = _maxSupply;
    setMaxMintAmountPerTxPublic(_maxMintAmountPerTxPublic);
    setMaxMintAmountPerTxRemilia(_maxMintAmountPerTxRemilia);
    setMaxMintAmountPerTxWhitelist(_maxMintAmountPerTxWhitelist);
    setHiddenMetadataUri(_hiddenMetadataUri);
  }

  modifier mintCompliance(uint256 _mintAmount, uint256 _maxMintAmountPerTx) {
    require(_mintAmount > 0 && _mintAmount <= _maxMintAmountPerTx, 'Invalid mint amount!');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
    _;
  }

  
  function publicMint(uint256 _mintAmount) public payable mintCompliance(_mintAmount, maxMintAmountPerTxPublic) {
    require(msg.value >= cost * _mintAmount, 'Insufficient funds!'); // Checks if enough Ether was sent
    require(!paused, 'Minting is paused'); // Additional check if you want to include pausing functionality
    _safeMint(_msgSender(), _mintAmount);

  }




  modifier mintPriceCompliance(uint256 _mintAmount) {
    require(msg.value >= cost * _mintAmount, 'Insufficient funds!');
    _;
  }

 function whitelistMint(uint256 _mintAmount) public payable mintCompliance(_mintAmount, maxMintAmountPerTxWhitelist) {
    require(whitelistedAddresses[msg.sender], "Address is not whitelisted!"); // Check if the sender's address is whitelisted
    require(!whitelistClaimed[msg.sender], 'Address already claimed!');
    if (whitelistCost > 0) {
        require(msg.value >= whitelistCost * _mintAmount, 'Insufficient funds for whitelist price!');
    }
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    require(!paused, 'Minting is paused');

    whitelistClaimed[msg.sender] = true;
    _safeMint(msg.sender, _mintAmount);
}




  function addToWhitelist(address[] memory _addresses) public onlyOwner {
   for (uint256 i = 0; i < _addresses.length; i++) {
     whitelistedAddresses[_addresses[i]] = true;
     whitelistClaimed[_addresses[i]] = false; 
   }
  }

  function addToRemilialist(address[] memory _addresses) public onlyOwner {
   for (uint256 i = 0; i < _addresses.length; i++) {
     remilialistedAddresses[_addresses[i]] = true;
     remilialistClaimed[_addresses[i]] = false; 
   }
  }

  
  function mintForAddress(uint256 _mintAmount, address _receiver) public onlyOwner {
    _safeMint(_receiver, _mintAmount);
  }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

    if (revealed == false) {
      return hiddenMetadataUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : '';
  }

  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }

  function setWhitelistCost(uint256 _whitelistCost) public onlyOwner {
    whitelistCost = _whitelistCost;
  }

  function setRemiliaCost(uint256 _remiliaCost) public onlyOwner {
    remiliaCost = _remiliaCost;
  }

  function setRemiliaSaleEnabled(bool _state) public onlyOwner {
    remiliaSaleEnabled = _state;
  }


  function remiliaMint(uint256 _mintAmount) public payable mintCompliance(_mintAmount, maxMintAmountPerTxRemilia) {
    require(!remilialistClaimed[_msgSender()], 'Address already claimed!');
    require(msg.value >= remiliaCost * _mintAmount, 'Insufficient funds for Remilia price!');
    require(remiliaSaleEnabled, 'The Remilia sale is not enabled!');
    require(!paused, 'Minting is paused'); 

    remilialistClaimed[_msgSender()] = true;
    _safeMint(_msgSender(), _mintAmount);
  }





  function setMaxMintAmountPerTxPublic(uint256 _amount) public onlyOwner {
    maxMintAmountPerTxPublic = _amount;
  }

  function setMaxMintAmountPerTxRemilia(uint256 _amount) public onlyOwner {
    maxMintAmountPerTxRemilia = _amount;
  }

  function setMaxMintAmountPerTxWhitelist(uint256 _amount) public onlyOwner {
    maxMintAmountPerTxWhitelist = _amount;
  }


  function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
    hiddenMetadataUri = _hiddenMetadataUri;
  }

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  

  function setWhitelistMintEnabled(bool _state) public onlyOwner { 
    whitelistMintEnabled = _state;
  }

  

  function withdraw() public onlyOwner nonReentrant {
    
    // =============================================================================
    
    // This will transfer the remaining contract balance to the owner.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}('');
    require(os);
    // =============================================================================
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }
}