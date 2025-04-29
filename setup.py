from setuptools import setup, find_packages
import wheel

setup(
    name="packaging_demo",
    version="0.0.0",
    packages=find_packages(),
    author="Bill Sahlas",
    author_email="bill.sahlas@gmail.com",
    description="My Package course work.",
    license="MIT",
    install_requires=["numpy"],
)
