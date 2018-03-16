/**
 * @name Google search
 * @desc Searches Google.com for a term and checks if the first link matches. This check should fail.
 */

const puppeteer = require('puppeteer')
const async = require('async')

let browser
let page

function done(e) {
    if (e) console.error(e);
    console.log("finished")
}

var a = async () => {
  browser = await puppeteer.launch({headless: false})
  page = await browser.newPage()
  await page.setViewport({ width: 1280, height: 800 })
}

var b = async () => {
    await page.goto('https://google.com', { waitUntil: 'networkidle0' })
    const title = await page.title()
    console.log(title)
    await page.waitForSelector("#lst-ib.gsfi")
    await page.click("#lst-ib.gsfi")
    await page.type("#lst-ib.gsfi", process.argv[2] || '')
    await page.waitForSelector('[name=btnK]')
    await page.click('[name=btnK]')
    await page.waitForSelector("#res.med.r.r")
    
    const headsets = await page("#res.med.r.r")
    await headsets[2].click()
}

var c = async () => {
await browser.close()
}

async.series([a, b,
    //  c
    ], done)