import React, { useState } from 'react';
import { useArweaveWallet } from '../contexts/ArweaveWalletContext';

const AR_TO_BIG = 1000000000000;

const Todo: React.FC = () => {
  const arweaveWallet = useArweaveWallet();
  const [arBalance, setArBalance] = useState<string>('0');

  const bigBalance = (balance / AR_TO_BIG).toFixed(4);
  setArBalance(bigBalance);

  return (
    <div>
      {/* Render your component content here */}
    </div>
  );
};

export default Todo; 