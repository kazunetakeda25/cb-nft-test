const hre = require('hardhat')

async function main() {
  const BASEURI1 = 'BASEURI:TODO'
  const CBNFT1 = await hre.ethers.getContractFactory('CBNFT1')
  const CBNFT1Instance = await CBNFT1.deploy(BASEURI1)
  console.log(`Deploying CBNFT1 at: ${CBNFT1Instance.address}`)
  await CBNFT1Instance.deployed()
  console.log('CBNFT1 deployed to:', CBNFT1Instance.address)

  const BASEURI2 = 'BASEURI:TODO'
  const CBNFT2 = await hre.ethers.getContractFactory('CBNFT2')
  const CBNFT2Instance = await CBNFT2.deploy(BASEURI2)
  console.log(`Deploying CBNFT2 at: ${CBNFT2Instance.address}`)
  await CBNFT2Instance.deployed()
  console.log('CBNFT2 deployed to:', CBNFT2Instance.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
