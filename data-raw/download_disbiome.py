import asyncio
from playwright.async_api import async_playwright
import os

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        
        # Enable download
        await page.goto("https://disbiome.ugent.be/export", wait_until="networkidle")
        print("Page loaded")
        
        # Looking for the export button, assuming there's a button containing "Export" or similar
        # Since it's an angular app, it might take a moment to render
        await page.wait_for_timeout(5000)
        
        # We find any button that might be it
        # Based on typical angular Material/Bootstrap apps
        try:
            # We trigger the download by clicking the export button
            async with page.expect_download() as download_info:
                # Find the button that triggers export
                await page.evaluate('''
                    const buttons = Array.from(document.querySelectorAll('button, a'));
                    const exportBtn = buttons.find(b => b.textContent.toLowerCase().includes('export') || b.textContent.toLowerCase().includes('download'));
                    if(exportBtn) exportBtn.click();
                ''')
            download = await download_info.value
            download_path = os.path.join("data-raw", "disbiome_export.csv")
            await download.save_as(download_path)
            print(f"Downloaded successfully to {download_path}")
        except Exception as e:
            print(f"Failed to download: {e}")
            
        await browser.close()

if __name__ == "__main__":
    asyncio.run(main())
