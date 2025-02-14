import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

with open("kineticstoolkit/VERSION", "r") as fh:
    version = fh.read()


setuptools.setup(
    name='kineticstoolkit',
    version=version,
    description='An open-source python library to facilitate research in biomechanics.',
    long_description=long_description,
    long_description_content_type="text/markdown",
    url='https://felixchenier.uqam.ca/kineticstoolkit',
    author='Félix Chénier',
    author_email='chenier.felix@uqam.ca',
    license='Apache',
        license_files=['LICENSE.txt', 'NOTICE.txt'],
    packages=setuptools.find_packages(),
    package_data={
        'kineticstoolkit': ['VERSION', 'logo.png', 'logo_hires.png'],
    },
    project_urls={
        'Documentation': 'https://felixchenier.uqam.ca/kineticstoolkit',
        'Source': 'https://github.com/felixchenier/kineticstoolkit/',
        'Tracker': 'https://github.com/felixchenier/kineticstoolkit/issues',
    },
    install_requires=['pandas',
                      'pyqt5',
                      'scipy',
                      'matplotlib',
                      'scikit-learn',
                      'limitedinteraction',
                      # 'ffmpeg',  # Facultative, for matplotlib html5 animations
                      ],
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: Apache Software License',
        'Natural Language :: English',
        'Operating System :: MacOS',
        'Operating System :: Microsoft :: Windows',
        'Operating System :: POSIX',
        'Programming Language :: Python :: 3',
    ],
    python_requires='>=3.8',
)
