//
//  ViewController.swift
//  p2pNewLib
//
//  Created by Stefan Haßferter on 15.03.19.
//  Copyright © 2019 adorsys GmbH & Co KG. All rights reserved.
//

import UIKit
import Web3


class ViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!

    var numberOfProposals = 0

    let privateKey = try! EthereumPrivateKey(hexPrivateKey: "0xb7553adc227436ddd9a41fa114f2248cc6247f80276726c3450b93861866d8b0")
    let etherNode = Web3( rpcURL: "http://172.16.121.109:8545")
    let contractAddress = EthereumAddress(hexString: "0x24aA30159759eE23421AA808c5d50998736D346e")
    var contract: DynamicContract?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        etherNode.clientVersion { (Web3Response) in
            print(Web3Response)
        }

        tableview.dataSource = self
        tableview.delegate = self


        guard let jsonAbi = loadAbi() else {return}

        contract = try! etherNode.eth.Contract(json: jsonAbi, abiKey: nil, address: contractAddress)

        guard let contract = contract else {return}

        let loadPropsalCount = contract["loadProposalCount"]!().createCall()
        contract.call(loadPropsalCount!, outputs: [.init(name: "_count", type: .uint8)]) { (response, error) in
            if let response = response,
                let item = response["_count"] as? UInt8
            {
                self.numberOfProposals = Int(item)
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }

            }

        }

        //
        //        let winningProposal = contract["winningProposal"]!().createCall()
        //        contract.call(winningProposal!, outputs: [.init(name: "_winningProposal", type: .uint8),
        //                                                  .init(name: "_winningVoteCount", type: .uint8)]) { (response, error) in
        //                                                    print(response!)
        //        }
        //
        //
        //        let c = contract["vote"]?(BigUInt(2))
        //
        //
        //
        //        etherNode.eth.getTransactionCount(address: privateKey.address, block: .latest){ response in
        //            print (response.result!.quantity)
        //
        //            let trans = c!.createTransaction(nonce: response.result!,
        //                                             from: privateKey.address,
        //                                             value: 0,
        //                                             gas: 38182,
        //                                             gasPrice: EthereumQuantity(quantity: 1.gwei))
        //
        //
        //            let signedTx = try! trans?.sign(with: privateKey,chainId: 5777)
        //
        //            etherNode.eth.sendRawTransaction(transaction: signedTx!) { response in
        //                print(response)
        //            }
        //
        //
        //            contract.call(winningProposal!, outputs: [.init(name: "_winningProposal", type: .uint8),
        //                                                      .init(name: "_winningVoteCount", type: .uint8)]) { (response, error) in
        //                                                        print(response!)
        //            }
        //
        //        }
        //



        //        contract.call(c, outputs: [.init(name: "toProposal", type: .uint8)]) { (response, error) in
        //                                                    print(response!)
        //        }
    }
}

extension ViewController{

    func loadAbi()->Data?{
        if let path = Bundle.main.path(forResource: "Abi", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            return data
        }
        return nil
    }

}


extension ViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfProposals
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "proposalCell")!
        cell.textLabel?.text = "Proposal #\(indexPath.row)"
        return cell
    }


}

extension ViewController:UITableViewDelegate{

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contract = contract else {return}

        let c = contract["vote"]?(BigUInt(indexPath.row))

        etherNode.eth.getTransactionCount(address: privateKey.address, block: .latest){ response in
            print (response.result!.quantity)

            let trans = c!.createTransaction(nonce: response.result!,
                                             from: self.privateKey.address,
                                             value: 0,
                                             gas: 38182,
                                             gasPrice: EthereumQuantity(quantity: 1.gwei))


            let signedTx = try! trans?.sign(with: self.privateKey,chainId: 5777)

            self.etherNode.eth.sendRawTransaction(transaction: signedTx!) { response in
                print(response)
            }
        }
    }
}

