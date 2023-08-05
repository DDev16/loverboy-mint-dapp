import React, { useState, useEffect } from 'react';
import Web3 from 'web3';
import LoverboyContract from '../../components/abi/Loverboy.js'; // Replace with your contract ABI and address
import "../../components/Styles/mintingDappStyles.css";
import boyloverImage from '../../Assets/boylover.JPG'; // Import the image
import bannerImage from '../../Assets/Enemigoz.JPG'; // Import the image
import Swal from 'sweetalert2';
import 'sweetalert2/dist/sweetalert2.min.css';

const MintingDapp = () => {
  const [web3, setWeb3] = useState(null);
  const [contract, setContract] = useState(null);
  const [account, setAccount] = useState(null);
  const [walletConnected, setWalletConnected] = useState(false); // New state variable for wallet connection
  const [mintAmount, setMintAmount] = useState(1);
  const [saleType, setSaleType] = useState('public'); // Default to public sale
  const [isLoading, setLoading] = useState(false);
  const [transactionHash, setTransactionHash] = useState(null);

  const contractAddress = '0x83F00B6578Ba7b3f39223A0e2Fe0d5dbF415E737'; // Replace with your deployed contract address
  const contractABI = LoverboyContract;

  useEffect(() => {
    const initializeWeb3 = async () => {
      if (window.ethereum) {
        const web3 = new Web3(window.ethereum);
        await window.ethereum.enable();
        setWeb3(web3);

        const contract = new web3.eth.Contract(contractABI.abi, contractAddress);
        setContract(contract);

        const accounts = await web3.eth.getAccounts();
        setAccount(accounts[0]);
      }
    };

    initializeWeb3();
  }, [contractABI.abi]); 

   // Function to connect the wallet
  const connectWallet = async () => {
    try {
      if (window.ethereum) {
        const web3 = new Web3(window.ethereum);
        await window.ethereum.enable();
        setWeb3(web3);

        const contract = new web3.eth.Contract(contractABI.abi, contractAddress);
        setContract(contract);

        const accounts = await web3.eth.getAccounts();
        setAccount(accounts[0]);
        setWalletConnected(true);
      }
    } catch (error) {
      console.error('Error while connecting wallet:', error);
    }
  };



  const handleMint = async () => {
    try {
      if (contract && account) {
        // Check the maximum allowed mint amount based on the selected sale type
        let maxMintAmount;
        if (saleType === 'public') {
          maxMintAmount = 20;
        } else if (saleType === 'whitelist') {
          maxMintAmount = 3;
        } else if (saleType === 'remilia') {
          maxMintAmount = 10;
        }

        // Check if the selected mint amount exceeds the maximum allowed
        if (mintAmount > maxMintAmount) {
          Swal.fire({
            icon: 'error',
            title: 'Oops...',
            text: `Exceeded maximum allowed mint amount (${maxMintAmount}) for the selected sale type.`,
          });
          return;
        }

        Swal.fire({
          title: 'Minting in progress...',
          html: 'Please wait while the transaction is being processed.',
          allowOutsideClick: false,
          onBeforeOpen: () => {
            Swal.showLoading();
          },
        });

        setLoading(true); // Show loading alert
        setTransactionHash(null); // Reset transaction hash

        let costInWei;
        if (saleType === 'public') {
          costInWei = web3.utils.toWei((mintAmount * 0.05).toString(), 'ether');
        } else if (saleType === 'whitelist') {
          costInWei = web3.utils.toWei((mintAmount * 0.03).toString(), 'ether');
        } else if (saleType === 'remilia') {
          costInWei = web3.utils.toWei((mintAmount * 0.02).toString(), 'ether');
        }

        // Use the correct function based on the sale type
        if (saleType === 'public') {
          const transaction = await contract.methods.publicMint(mintAmount).send({
            from: account,
            value: costInWei,
          });

          setTransactionHash(transaction.transactionHash);
        } else if (saleType === 'whitelist') {
          await contract.methods.whitelistMint(mintAmount).send({
            from: account,
            value: costInWei,
          });
        } else if (saleType === 'remilia') {
          await contract.methods.remiliaMint(mintAmount).send({
            from: account,
            value: costInWei,
          });
        }

        setLoading(false); // Hide loading alert

        Swal.fire({
          icon: 'success',
          title: 'Success!',
          text: 'Minting successful!',
        });
      }
    } catch (error) {
      console.error('Error while minting:', error);
      setLoading(false); // Hide loading alert

      Swal.fire({
        icon: 'error',
        title: 'Oops...',
        text: 'Error while minting. Please try again later.',
      });
    }
  };

  // Calculate minting prices for each option
  const mintingPrices = {
    public: mintAmount * 0.05,
    whitelist: mintAmount * 0.03,
    discount: mintAmount * 0.02,
  };

  // Calculate the maximum allowed mint amount based on the selected sale type
  let maxMintAmount;
  if (saleType === 'public') {
    maxMintAmount = 20;
  } else if (saleType === 'whitelist') {
    maxMintAmount = 3;
  } else if (saleType === 'remilia') {
    maxMintAmount = 10;
  }

  
  return (
    <div>
      <img src={bannerImage} alt="NFT Placeholder" className='banner' />

      {walletConnected ? ( // Show the minting dApp container if the wallet is connected
        <div className="container">
          {account && (
            <div className="account-container">
              <p className="account">Connected account: {account}</p>
            </div>
          )}
          <label htmlFor="saleType">Select Sale Type:</label>
          <select id="saleType" value={saleType} onChange={(e) => setSaleType(e.target.value)}>
            <option value="public">Public Sale - Cost: {mintingPrices.public} ETH</option>
            <option value="whitelist">Whitelist Sale - Cost: {mintingPrices.whitelist} ETH</option>
            <option value="remilia">Discount Sale - Cost: {mintingPrices.discount} ETH</option>
          </select>
          <img src={boyloverImage} alt="NFT Placeholder" className='image' />

          <input
            type="number"
            min="1"
            max={maxMintAmount}
            value={mintAmount}
            onChange={(e) => setMintAmount(parseInt(e.target.value))}
          />
          <button onClick={handleMint} disabled={isLoading || mintAmount > maxMintAmount}>
            {isLoading ? 'Minting in Progress...' : `Mint ${mintAmount} NFTs`}
          </button>
          {transactionHash && (
            <p className="transaction-hash">
              Transaction Hash: <a href={`https://etherscan.io/tx/${transactionHash}`} target="_blank" rel="noopener noreferrer">{transactionHash}</a>
            </p>
          )}
        </div>
      ) : ( // Show the "Connect Wallet" button if the wallet is not connected
        <div className="connect-wallet-container">
          <button onClick={connectWallet}>Connect Wallet</button>
        </div>
      )}
    </div>
  );
};

export default MintingDapp;