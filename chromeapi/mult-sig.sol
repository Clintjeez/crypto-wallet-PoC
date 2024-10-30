// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    address[] public owners;
    uint public requiredApprovals;
    mapping(uint => mapping(address => bool)) public approvals;
    
    struct Transaction {
        address payable to;
        uint amount;
        bool executed;
    }
    Transaction[] public transactions;

    constructor(address[] memory _owners, uint _requiredApprovals) {
        owners = _owners;
        requiredApprovals = _requiredApprovals;
    }

    function submitTransaction(address payable _to, uint _amount) public onlyOwner {
        transactions.push(Transaction({
            to: _to,
            amount: _amount,
            executed: false
        }));
    }

    function approveTransaction(uint _txIndex) public onlyOwner {
        require(!approvals[_txIndex][msg.sender], "Already approved");
        approvals[_txIndex][msg.sender] = true;
    }

    function executeTransaction(uint _txIndex) public onlyOwner {
        Transaction storage txn = transactions[_txIndex];
        require(txn.executed == false, "Transaction already executed");
        
        uint count = 0;
        for(uint i = 0; i < owners.length; i++) {
            if(approvals[_txIndex][owners[i]]) count++;
        }
        
        require(count >= requiredApprovals, "Not enough approvals");
        txn.executed = true;
        txn.to.transfer(txn.amount);
    }
    
    modifier onlyOwner() {
        bool isOwner = false;
        for(uint i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Not an owner");
        _;
    }
}
