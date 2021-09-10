/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer } from "ethers";
import { Provider } from "@ethersproject/providers";

import type { IChainLinkFeedsMap } from "../IChainLinkFeedsMap";

export class IChainLinkFeedsMap__factory {
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IChainLinkFeedsMap {
    return new Contract(address, _abi, signerOrProvider) as IChainLinkFeedsMap;
  }
}

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "feed",
        type: "address",
      },
    ],
    name: "isChainLinkFeed",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];
