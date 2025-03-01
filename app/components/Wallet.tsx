import React, { useState } from 'react';

const AR_TO_BIG = 1000000000000;

const Wallet: React.FC = () => {
  const [arBalance, setArBalance] = useState<string>('0');

  const bigBalance = (balance / AR_TO_BIG).toFixed(4);
  setArBalance(bigBalance);

  return (
    <div>
      {/* Render your component content here */}
    </div>
  );
};

export default Wallet; 